defmodule NewsBite.Utils.SummariseTest do
  use ExUnit.Case, async: true
  alias NewsBite.Utils.Summarise

  # test "to_key_words/1 returns top words" do
  #   word_list = ["dog", "cat", "cat", "dog", "apple", "cherry", "human", "dog", "apple"]
  #   stop_words_sample = ["actually", "about", "this", "he", "he", "he"]
  #   symbol_sample = ["@", "/", "]", "@", "@"]

  #   key_words =
  #     [word_list, stop_words_sample, symbol_sample]
  #     |> List.flatten()
  #     |> Enum.shuffle()
  #     |> Summarise.to_key_words(3)

  #   assert key_words == [{"dog", 3}, {"cat", 2}, {"apple", 2}]
  # end
  test "group_by_top_words/1 returns top words" do
    word_list = [
      {1, "dog"},
      {1, "cat"},
      {1, "cat"},
      {1, "dog"},
      {2, "@pple"},
      {1, "che@rry"},
      {3, "dog"},
      {3, "@pple"}
    ]

    stop_words_sample = ["actually", "about", "this", "he", "he", "he"]
    symbol_sample = ["@", "/", "]", "@", "@"]

    key_words =
      [word_list, stop_words_sample, symbol_sample]
      |> List.flatten()
      |> Enum.shuffle()
      |> Summarise.group_by_top_words()

    assert key_words == [
             %{word: "dog", frequency: 3, ids: [1, 3]},
             %{word: "cat", frequency: 2, ids: [1]},
             %{word: "@pple", frequency: 2, ids: [3, 2]},
             %{word: "che@rry", frequency: 1, ids: [1]}
           ]
  end
end
