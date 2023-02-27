defmodule NewsBite.BiteCache do
  @namespace :bite_cache

  alias NewsBite.{Bite, Bites}

  use GenServer

  def start_link(_attrs) do
    GenServer.start_link(__MODULE__, %{}, name: @namespace)
  end

  @impl true
  def init(_) do
    start()
    {:ok, %{scheduled: schedule_news_refresh()}}
  end

  @spec start :: :ok | {:error, :already_started}
  def start do
    :ets.new(@namespace, [:named_table, :public, :set])
    :ok
  rescue
    ArgumentError -> {:error, :already_started}
  end

  def pid(), do: self()

  def list_bites() do
    :ets.tab2list(@namespace)
  end

  def get_bite(id) do
    with lookup when lookup != [] <-
           :ets.lookup(@namespace, id),
         {_key, bite} <-
           List.first(lookup) do
      bite
    else
      _ -> {:error, :not_found}
    end
  end

  def upsert_bite(%Bite{} = bite) do
    :ets.insert(@namespace, {bite.id, bite})
    bite
  end

  def delete_bite(id) do
    :ets.delete(@namespace, id)
  end

  # TODO: Need a fallback for when news refreshing fails
  @impl true
  def handle_info({:refresh_news, caller_pid}, state) do
    list_bites()
    |> Enum.map(fn {_id, bite} -> upsert_bite(bite) end)

    Process.cancel_timer(state.scheduled)

    if caller_pid do
      Phoenix.PubSub.broadcast(NewsBite.PubSub, "live_update", "bites_refreshed")
    else
      Phoenix.PubSub.broadcast(NewsBite.PubSub, "live_update", "update_available")
    end

    {:noreply, %{scheduled: schedule_news_refresh()}}
  end

  defp schedule_news_refresh(retrieval_rate \\ 4) do
    Process.send_after(self(), {:refresh_news, nil}, retrieval_rate * 60 * 60 * 1000)
  end
end
