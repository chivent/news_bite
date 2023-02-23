defmodule NewsBite.Api.NewsApi do
  alias NewsBite.{Bite, Utils}

  @api_key Application.compile_env(:news_bite, :news_api_key)

  def get_news_list(:mock) do
    filename = Application.app_dir(:news_bite, "priv/static/mock_news_source.json")

    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body) do
      {:ok, Utils.atomize_map_keys(json["articles"])}
    else
      _ -> {:error}
    end
  end

  def get_news_list(bite) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Api-Key", @api_key}
    ]

    request =
      "https://newsapi.org/v2/top-headlines"
      |> URI.parse()
      |> add_query(bite)
      |> URI.to_string()

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(request, headers),
         {:ok, json} <- Jason.decode(body) do
      # Get probably totalResults?
      {:ok, Utils.atomize_map_keys(json["articles"])}
    else
      _error ->
        {:error}
    end

    # TODO: To also secure API Key
  end

  defp add_query(uri, %Bite{} = bite) do
    # TODO: Make page size configurable later
    query =
      %{language: "en"}
      |> maybe_add_opt(:search_terms, bite)
      |> maybe_add_opt(:country, bite)
      |> maybe_add_opt(:category, bite)
      |> Map.put("pageSize", 100)
      |> Map.put("sortBy", "relevance")
      |> URI.encode_query()

    Map.put(uri, :query, query)
  end

  defp maybe_add_opt(query, :search_terms, %Bite{search_terms: search_terms})
       when not is_nil(search_terms) do
    search_terms = Enum.join(search_terms, " AND ")
    Map.put(query, :q, search_terms)
  end

  defp maybe_add_opt(query, :country, %Bite{country: country}) when not is_nil(country) do
    Map.put(query, :country, Atom.to_string(country))
  end

  defp maybe_add_opt(query, :category, %Bite{category: category}) when not is_nil(category) do
    Map.put(query, :category, Atom.to_string(category))
  end

  defp maybe_add_opt(query, _, _), do: query
end
