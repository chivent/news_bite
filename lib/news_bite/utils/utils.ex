defmodule NewsBite.Utils do
  @moduledoc false

  @doc """
  Turns the keys of a map from strings to atoms
  """
  def atomize_map_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {String.to_atom(key), atomize_map_keys(value)} end)
    |> Enum.into(%{})
  end

  def atomize_map_keys(list) when is_list(list) do
    Enum.map(list, &atomize_map_keys(&1))
  end

  def atomize_map_keys(arg), do: arg

  @doc """
  Adds an empty option to a list of values: To be used in options tag
  """
  def optional_options(options) do
    options = Enum.map(options, &{&1, &1})

    [{"None", nil} | options]
  end
end
