defmodule NewsBite.BiteCacheTest do
  use ExUnit.Case
  alias NewsBite.{Bite, BiteCache}

  @namespace :bite_cache

  setup do
    start_supervised(BiteCache)
    :ok
  end

  test "list_bites returns a list of all stored bites" do
    sample_one = {1, "sample"}
    sample_two = {2, "sample_2"}
    :ets.insert(@namespace, sample_one)
    :ets.insert(@namespace, sample_two)

    result = BiteCache.list_bites()
    assert Enum.sort(result) == [sample_one, sample_two]
  end

  describe "get_bite/1" do
    test "returns bite" do
      sample = %Bite{id: 1}
      :ets.insert(@namespace, {1, sample})
      assert BiteCache.get_bite(sample.id) == sample
    end

    test "returns error if bite is not found" do
      assert BiteCache.get_bite(:unknown) == {:error, :not_found}
    end
  end

  describe "upsert_bite/1" do
    test "successfully inserts a new bite" do
      sample = %Bite{id: 1}
      BiteCache.upsert_bite(sample)
      assert [{1, _}] = :ets.lookup(@namespace, sample.id)
    end

    test "successfully updates an existing bite" do
      sample = %Bite{id: 1}
      :ets.insert(@namespace, {1, sample})

      updated_sample = %Bite{id: 1, country: :uk}
      BiteCache.upsert_bite(updated_sample)
      assert [{1, ^updated_sample}] = :ets.lookup(@namespace, sample.id)
    end

    test "returns associated error after inserting bite" do
      sample = {:api_error, %Bite{id: 1}, "message"}
      response = BiteCache.upsert_bite({:api_error, bite, "message"})
      assert [{1, _}] = :ets.lookup(@namespace, sample.id)
      assert ^sample = response
    end
  end

  test "delete_bite/1 deletes bite" do
    sample = %Bite{id: 1}
    :ets.insert(@namespace, {1, sample})
    BiteCache.delete_bite(1)
    assert BiteCache.get_bite(sample.id) == {:error, :not_found}
  end

  describe "handle_info: refresh_news" do
    setup do
      Phoenix.PubSub.subscribe(NewsBite.PubSub, "live_update")
      sample_one = {1, %Bite{id: 1, country: :uk}}
      :ets.insert(@namespace, sample_one)
      :ok
    end

    test "successfully schedules the next refresh for all bites" do
      sample_two = {2, %Bite{id: 2, country: :us}}
      :ets.insert(@namespace, sample_two)

      {:noreply, new_state} = BiteCache.handle_info({:refresh_news, true}, %{})
      assert_receive({"bites_refreshed", :ok})

      assert Map.has_key?(new_state, :scheduled)
      Process.cancel_timer(new_state.scheduled)
    end

    test "successfully receives update_available broadcast" do
      sample_one = {1, %Bite{id: 1, country: :uk}}
      :ets.insert(@namespace, sample_one)

      {:noreply, new_state} = BiteCache.handle_info({:refresh_news, nil}, %{})
      assert_receive("update_available")

      Process.cancel_timer(new_state.scheduled)
    end

    test "halts the refresh if there is an api error in the midst of refreshing" do
      sample_two = {2, %Bite{id: 2, search_term: "failure:unknown"}}
      :ets.insert(@namespace, sample_two)

      {:noreply, new_state} = BiteCache.handle_info({:refresh_news, true}, %{})
      assert_receive({"bites_refreshed", {:api_error, "an error occured."}})

      Process.cancel_timer(new_state.scheduled)
    end
  end
end
