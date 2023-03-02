defmodule NewsBite.Article do
  @moduledoc """
  The Article struct.
  """
  defstruct [:id, :title, :description, :url]
end

defmodule NewsBite.ArticleGroup do
  @moduledoc """
  The ArticleGroup struct, which represents a group of articles associated with a commonly apearing word
  """
  defstruct [:word, :frequency, :articles]
end

defmodule NewsBite.Articles do
  @moduledoc """
  The Articles context.
  """
  alias NewsBite.Api.NewsApi
  alias NewsBite.Articles
  alias NewsBite.Utils.Grouping

  @doc """
  Returns a bite's top article word groups
  """
  def get_latest_article_groups(bite) do
    case get_articles_by_bite(bite) do
      [] ->
        []

      {:api_error, reason} ->
        {:api_error, reason}

      articles ->
        articles
        |> articles_into_words()
        |> Grouping.group_by_top_words()
    end
  end

  @doc """
  Creates a new article
  """
  @spec new_article(any) :: %{:__struct__ => atom, :id => <<_::288>>, optional(atom) => any}
  def new_article(attrs) do
    %NewsBite.Article{}
    |> struct(attrs)
    |> Map.put(:id, Ecto.UUID.autogenerate())
  end

  defp articles_into_words(articles) do
    articles
    |> Enum.map(&article_into_words(&1))
    |> Enum.reduce(fn words, acc -> words ++ acc end)
  end

  # Turns an article's description and title into a list of {article, word}
  @spec article_into_words(atom | %{:description => any, :title => any, optional(any) => any}) ::
          [binary]
  defp article_into_words(article) do
    "#{remove_title_source(article.title)} #{article.description}"
    |> String.downcase()
    |> String.trim()
    |> String.replace([",", "."], "")
    |> String.split(" ")
    |> Enum.map(fn word -> {article, word} end)
  end

  defp get_articles_by_bite(bite) do
    with {:ok, json} <- NewsApi.get_news_list(bite) do
      Enum.map(json, &Articles.new_article(&1))
    else
      error -> error
    end
  end

  defp remove_title_source(title) when not is_nil(title) do
    Regex.replace(~r/-\s(?:(?!-\s).)+$/, title, "")
  end

  defp remove_title_source(_), do: ""
end
