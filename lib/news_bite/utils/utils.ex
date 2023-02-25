defmodule NewsBite.Utils do
  def atomize_map_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {String.to_atom(key), atomize_map_keys(value)} end)
    |> Enum.into(%{})
  end

  def atomize_map_keys(list) when is_list(list) do
    Enum.map(list, &atomize_map_keys(&1))
  end

  def atomize_map_keys(arg), do: arg

  def optional_options(options) do
    options = Enum.map(options, &{&1, &1})

    [{"None", nil} | options]
  end
end
