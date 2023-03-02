defmodule NewsBite.UtilsTest do
  use ExUnit.Case, async: true

  alias NewsBite.Utils

  describe "atomize_map_keys/1" do
    test "turns string keys of a map into atoms" do
      result =
        %{"key" => "test", "key_two" => "test"}
        |> Utils.atomize_map_keys()

      assert %{key: "test", key_two: "test"} = result
    end

    test "turns string keys of a list of maps into atoms" do
      result =
        [%{"key" => "test", "key_two" => "test"}, %{"other_map" => "test"}]
        |> Utils.atomize_map_keys()

      assert %{key: "test", key_two: "test"} in result
      assert %{other_map: "test"} in result
    end

    test "returns the arg as is if not a list or map" do
      result = Utils.atomize_map_keys(["test"])

      assert ["test"] = result
    end
  end

  test "optional_options/1 adds an empty option to a list of select options" do
    result = Utils.optional_options(["A", "B"])
    assert [{"None", nil}, {"A", "A"}, {"B", "B"}] = result
  end
end
