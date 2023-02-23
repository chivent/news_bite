defmodule NewsBite.Utils.SummaryStopWords do
  # Add a doc expanation for stop words
  def list() do
    filename = Application.app_dir(:news_bite, "priv/static/stop_words_english.json")

    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body) do
      json
    end
  end
end

defmodule NewsBite.Utils.Summarise do
  @stop_words NewsBite.Utils.SummaryStopWords.list()

  def group_by_top_words(word_list) do
    word_list
    |> List.flatten()
    |> Enum.reject(&word_is_invalid?(&1))
    |> Enum.group_by(fn {_id, word} -> word end, fn {article, _word} -> article end)
    |> Enum.map(fn {word, article_list} ->
      %{word: word, frequency: length(article_list), articles: Enum.uniq(article_list)}
    end)
    |> Enum.sort(fn group, other -> group.frequency > other.frequency end)
    |> Enum.take(10)
  end

  defp not_a_word?(word), do: !Regex.match?(~r/[A-Za-z]+/, word)

  defp word_is_invalid?({_id, word}), do: word_is_invalid?(word)
  defp word_is_invalid?(word), do: not_a_word?(word) || word in @stop_words
end
