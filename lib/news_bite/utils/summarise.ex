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

  def to_key_words(word_list, limit \\ 10) do
    word_list
    |> Enum.reject(&word_is_invalid?(&1))
    |> Enum.frequencies()
    |> Enum.sort(fn {_, frequency}, {_, other_frequency} -> frequency > other_frequency end)
    |> Enum.take(limit)
  end

  defp not_a_word?(word), do: !Regex.match?(~r/[A-Za-z]+/, word)

  defp word_is_invalid?(word), do: not_a_word?(word) || word in @stop_words
end
