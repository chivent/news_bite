defmodule NewsBite.BiteCacheTest do
  use ExUnit.Case
  alias Doyobi.Cache

  @namespace :bite_cache

  setup do
    {:ok, _} = BiteCache.start_link(@namespace)

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
      assert BiteCache.get_bite(1) == {:error, :not_found}
    end
  end

  # Update this to work with test data on news retrieval
  # describe "upsert_bite/1" do
  #   test "successfully inserts a new bite" do
  #     sample = %Bite{id: 1}
  #     BiteCache.upsert_bite()
  #     assert :ets.lookup(@namespace, sample.id) == [sample]
  #   end

  #   test "successfully updates an existing bite" do
  #     sample = %Bite{id: 1}
  #     :ets.insert(@namespace, {1, sample})

  #     updated_sample = %Bite{id: 1, duration: :year}
  #     BiteCache.upsert_bite(updated_sample)
  #     assert :ets.lookup(@namespace, updated_sample) == [%{bite: updated_sample, summary: ]
  #   end
  # end

  # Update this to work with test data on news retrieval
  test "upsert_bite_summary/1 updates the summary of an existing bite" do
  end
end
