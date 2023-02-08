defmodule NewsBite.Utils.SummariseTest do
  use ExUnit.Case, async: true
  alias NewsBite.Utils.Summarise

  test "to_key_words/1 returns top words" do
    word_list = ["dog", "cat", "cat", "dog", "apple", "cherry", "human", "dog", "apple"]
    stop_words_sample = ["actually", "about", "this", "he", "he", "he"]
    symbol_sample = ["@", "/", "]", "@", "@"]

    key_words =
      [word_list, stop_words_sample, symbol_sample]
      |> List.flatten()
      |> Enum.shuffle()
      |> Summarise.to_key_words(3)

    assert key_words == [{"dog", 3}, {"cat", 2}, {"apple", 2}]
  end
end
