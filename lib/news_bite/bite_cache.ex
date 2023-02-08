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
    schedule_news_refresh()
    {:ok, nil}
  end

  @spec start :: :ok | {:error, :already_started}
  def start do
    :ets.new(@namespace, [:named_table, :public, :set])
    :ok
  rescue
    ArgumentError -> {:error, :already_started}
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
    :ets.insert(@namespace, {bite.id, %{bite: bite, summary: nil}})
    upsert_bite_summary(bite)
  end

  def upsert_bite_summary(%Bite{} = bite) do
    summary = Bites.generate_bite_summary(bite)
    :ets.insert(@namespace, {bite.id, %{bite: bite, summary: summary}})
  end

  def delete_bite(id) do
    :ets.delete(@namespace, id)
  end

  @impl true
  def handle_info(:refresh_news, state) do
    :ets.tab2list(@namespace)
    |> Enum.map(fn {_id, %{bite: bite}} -> upsert_bite_summary(bite) end)

    schedule_news_refresh()
    {:noreply, state}
  end

  defp schedule_news_refresh(retrieval_rate \\ 2) do
    Process.send_after(self(), :refresh_news, retrieval_rate * 60 * 60 * 1000)
  end

  # @impl true
  # def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
  #   # Save to db?
  # end
end
