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
      %Article{id: 1, title: "This is a title 1", description: "This is a description"},
      %Article{id: 2, title: "This is a title 2", description: nil}
    ]

    result = Articles.articles_into_words(articles)

    expected = [
      {1, "this"},
      {1, "is"},
      {1, "a"},
      {1, "title"},
      {1, "1"},
      {1, "this"},
      {1, "is"},
      {1, "a"},
      {1, "description"},
      {2, "this"},
      {2, "is"},
      {2, "a"},
      {2, "title"},
      {2, "2"}
    ]

    assert Enum.sort(result) == Enum.sort(expected)
  end
end
