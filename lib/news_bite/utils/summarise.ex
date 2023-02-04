defmodule NewsBite.Utils.SummaryStopWords do
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

  def articles_to_key_words(articles) do
    articles
    |> Enum.map(&article_into_words(&1))
    |> Enum.reduce(fn words, acc -> words ++ acc end)
    |> Enum.reject(&word_is_invalid?(&1))
    |> Enum.frequencies()
    |> Enum.sort(fn {_, frequency}, {_, other_frequency} -> frequency > other_frequency end)
  end

  defp article_into_words(article) do
    "#{article.title} #{article.description}"
    |> String.downcase()
    |> String.trim()
    |> String.split(" ")
  end

  defp not_a_word?(word), do: !Regex.match?(~r/\w/, word)

  defp word_is_invalid?(word), do: not_a_word?(word) || word in @stop_words
end
