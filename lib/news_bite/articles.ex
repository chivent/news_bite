defmodule NewsBite.Article do
  defstruct [:id, :title, :description, :content, :published_at, :url]
end

defmodule NewsBite.Articles do
  alias NewsBite.Api.NewsApi
  alias NewsBite.Articles

  def get_articles(_bite) do
    {:ok, json} = NewsApi.get_news_list(:mock)
    Enum.map(json, &Articles.new_article(&1))
  end

  def new_article(attrs) do
    %NewsBite.Article{}
    |> struct(attrs)
    |> Map.put(:id, Ecto.UUID.autogenerate())
  end
end
