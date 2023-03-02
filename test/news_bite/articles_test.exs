defmodule NewsBite.ArticlesTest do
  use ExUnit.Case, async: true
  alias NewsBite.{Article, Articles, Bite}

  describe "get_latest_article_groups/1" do
    test "on success returns bite's latest articles grouped by words" do
      article_groups =
        %Bite{search_term: "x2"}
        |> Articles.get_latest_article_groups()

      {first_group, rest} = List.pop_at(article_groups, 0)
      assert %NewsBite.ArticleGroup{word: "title", frequency: 2} = first_group

      {first_group, rest} = List.pop_at(rest, 0)
      assert %NewsBite.ArticleGroup{word: "description", frequency: 2} = first_group

      {first_group, rest} = List.pop_at(rest, 0)
      assert %NewsBite.ArticleGroup{word: "x22", frequency: 1} = first_group

      {first_group, rest} = List.pop_at(rest, 0)
      assert %NewsBite.ArticleGroup{word: "x2", frequency: 1} = first_group
    end

    test "on failure: returns error" do
      error = %Bite{search_term: "failure:unknown"} |> Articles.get_latest_article_groups()
      assert {:api_error, _reason} = error
    end
  end

  test "new_article/1 defines a new article struct" do
    params = %{
      title: "New Title",
      description: "Description",
      url: "www.test.com",
      unknown: ""
    }

    article = Articles.new_article(params)
    assert Map.has_key?(article, :id)
    refute Map.has_key?(article, :unknown)
    assert %Article{} = article
    assert Map.get(article, :title) == "New Title"
    assert Map.get(article, :description) == "Description"
    assert Map.get(article, :url) == "www.test.com"
  end

  defp generate_article(title) do
    attrs =
      NewsBite.Api.MockNewsApi.article_template(title)
      |> NewsBite.Utils.atomize_map_keys()

    struct(%NewsBite.Article{}, attrs)
  end
end
