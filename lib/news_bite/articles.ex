defmodule NewsBite.Article do
  defstruct [:id, :title, :description, :content, :url]
end

defmodule NewsBite.ArticleGroup do
  defstruct [:word, :frequency, :articles]
end

defmodule NewsBite.Articles do
  alias NewsBite.Api.NewsApi
  alias NewsBite.Articles
  alias NewsBite.Utils.Grouping

  def get_articles_by_bite(bite) do
    with {:ok, json} <- NewsApi.get_news_list(bite) do
      Enum.map(json, &Articles.new_article(&1))
    else
      error -> error
    end
  end

  def get_article_groups(bite) do
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

  @spec new_article(any) :: %{:__struct__ => atom, :id => <<_::288>>, optional(atom) => any}
  def new_article(attrs) do
    %NewsBite.Article{}
    |> struct(attrs)
    |> Map.put(:id, Ecto.UUID.autogenerate())
  end

  def articles_into_words(articles) do
    articles
    |> Enum.map(&article_into_words(&1))
    |> Enum.reduce(fn words, acc -> words ++ acc end)
  end

  @spec article_into_words(atom | %{:description => any, :title => any, optional(any) => any}) ::
          [binary]
  def article_into_words(article) do
    "#{remove_title_source(article.title)} #{article.description}"
    |> String.downcase()
    |> String.trim()
    |> String.replace([",", "."], "")
    |> String.split(" ")
    |> Enum.map(fn word -> {article, word} end)
  end

  defp remove_title_source(title) when not is_nil(title) do
    Regex.replace(~r/-\s(?:(?!-\s).)+$/, title, "")
  end

  defp remove_title_source(_), do: ""
end
