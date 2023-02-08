defmodule NewsBite.ArticlesTest do
  use ExUnit.Case, async: true
  alias NewsBite.{Article, Articles}

  test "get_articles_by_bite/1 returns articles based on a bite" do
    # TODO
  end

  test "new_article/1 defines a new article struct" do
    params = %{
      title: "New Title",
      description: "Description",
      content: "Content",
      url: "www.test.com",
      unknown: ""
    }

    article = Articles.new_article(params)
    assert Map.has_key?(article, :id)
    refute Map.has_key?(article, :unknown)
    assert %Article{} = article
    assert Map.get(article, :title) == "New Title"
    assert Map.get(article, :description) == "Description"
    assert Map.get(article, :content) == "Content"
    assert Map.get(article, :url) == "www.test.com"
  end

  test "articles_into_words/1 turns a list of articles into words" do
    articles = [
      %Article{title: "This is a title 1", description: "This is a description"},
      %Article{title: "This is a title 2", description: nil}
    ]

    result = Articles.articles_into_words(articles)

    expected = [
      "this",
      "is",
      "a",
      "title",
      "1",
      "this",
      "is",
      "a",
      "description",
      "this",
      "is",
      "a",
      "title",
      "2"
    ]

    assert Enum.sort(result) == Enum.sort(expected)
  end
end
