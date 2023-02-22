defmodule NewsBite.Article do
  defstruct [:id, :title, :description, :content, :url]
end

defmodule NewsBite.Articles do
  alias NewsBite.Api.NewsApi
  alias NewsBite.Articles

  # TODO: Add fallback for failure case
  def get_articles_by_bite(bite) do
    {:ok, json} = NewsApi.get_news_list(:mock)

    Enum.map(json, &Articles.new_article(&1))
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
  end

  defp remove_title_source(title) when not is_nil(title) do
    Regex.replace(~r/-\s(?:(?!-\s).)+$/, title, "")
  end

  defp remove_title_source(_), do: ""
end
