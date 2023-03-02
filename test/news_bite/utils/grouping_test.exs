defmodule NewsBite.Utils.GroupingTest do
  use ExUnit.Case, async: true
  alias NewsBite.Utils.Grouping

  test "group_by_top_words/1 returns top words and their associated articles" do
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
      |> Grouping.group_by_top_words()

    assert key_words == [
             %NewsBite.ArticleGroup{word: "dog", frequency: 2, articles: [1, 3]},
             %NewsBite.ArticleGroup{word: "cat", frequency: 1, articles: [1]},
             %NewsBite.ArticleGroup{word: "@pple", frequency: 2, articles: [2, 3]},
             %NewsBite.ArticleGroup{word: "che@rry", frequency: 1, articles: [1]}
           ]
  end
end
