defmodule NewsBite.Api.NewsApiTest do
  alias NewsBite.Api.NewsApi
  alias NewsBite.{Article, Bite}
  use ExUnit.Case

  describe "get_news_list/1" do
    test "on success with params: returns a list of articles from top-headlines" do
      bite = %Bite{country: :us, category: :business, search_term: "apple"}

      assert {:ok, response} = NewsApi.get_news_list(bite)
      assert_articles_match("business us top_headlines apple", response)
    end

    test "on success with only category params: returns a list of articles from top-headlines" do
      bite = %Bite{category: :business}

      assert {:ok, response} = NewsApi.get_news_list(bite)
      assert_articles_match("business us top_headlines", response)
    end

    test "on success with no params: returns a list of articles from everything" do
      bite = %Bite{}

      assert {:ok, response} = NewsApi.get_news_list(bite)
      assert_articles_match("everything", response)
    end

    test "on success with only search term params: returns a list of articles from everything" do
      bite = %Bite{search_term: "apple"}

      assert {:ok, response} = NewsApi.get_news_list(bite)
      assert_articles_match("everything apple", response)
    end

    test "on api error failure: returns api key error message" do
      bite = %Bite{search_term: "failure:unknown"}
      assert {:api_error, error_message} = NewsApi.get_news_list(bite)

      assert error_message == "an error occured."
    end

    test "on exhuasted failure: returns api key error message" do
      bite = %Bite{search_term: "failure:apiKeyDisabled"}
      assert {:api_error, error_message} = NewsApi.get_news_list(bite)

      assert error_message ==
               "an error has arisen in the service key, please contact the developer."
    end

    test "on rate limited failure: returns exhausted error message" do
      bite = %Bite{search_term: "failure:apiKeyExhausted"}
      assert {:api_error, error_message} = NewsApi.get_news_list(bite)

      assert error_message == "the Bite refresh limit has been reached for the day."
    end

    test "on unknown failure: returns rate limited error message" do
      bite = %Bite{search_term: "failure:rateLimited"}
      assert {:api_error, error_message} = NewsApi.get_news_list(bite)

      assert error_message ==
               "too many refreshes have been made in a short period of time. Please wait a bit before trying again."
    end
  end

  defp assert_articles_match(title, response) do
    article = %{
      title: "This is a #{title} title",
      description: "This is a #{title} description",
      url: "https://localhost:8000/article_1",
      publishedAt: "2023-01-27T12:00:27Z"
    }

    assert match?([^article], response)
  end
end
