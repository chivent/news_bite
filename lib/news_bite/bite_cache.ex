defmodule NewsBite.BiteCache do
  @namespace :bite_cache

  use GenServer

  def start_link(_attrs) do
    GenServer.start_link(__MODULE__, %{}, name: @namespace)
  end

  @impl true
  def init(_) do
    start()
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
    {_key, bite} =
      :ets.lookup(@namespace, id)
      |> List.first()

    bite
  end

  @spec upsert_bite(atom | %{:id => any, optional(any) => any}) :: true
  def upsert_bite(bite) do
    :ets.insert(@namespace, {bite.id, bite})
  end

  def delete_bite(id) do
    :ets.delete(@namespace, id)
  end

  # @impl true
  # def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
  #   # Save to db?
  # end
end
