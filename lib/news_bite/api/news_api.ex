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
      {:ok, Utils.atomize_map_keys(json["articles"])}
    else
      {:error, %HTTPoison.Response{status_code: 401}} ->
        {:error, "An error has arisen in the service key, please contact the developer."}

      {:error, %HTTPoison.Response{status_code: 429}} ->
        {:error, :too_many_calls}

      _ ->
        {:error, "An error has occured, please try again."}
    end
  end

  defp add_query(uri, %Bite{} = bite) do
    query =
      %{}
      |> maybe_add_opt(:search_term, bite)
      |> maybe_add_opt(:country, bite)
      |> maybe_add_opt(:category, bite)
      |> Map.put("pageSize", 100)
      |> Map.put("sortBy", "relevance")
      |> URI.encode_query()

    Map.put(uri, :query, query)
  end

  defp maybe_add_opt(query, :search_term, %Bite{search_term: search_term})
       when not is_nil(search_term) do
    Map.put(query, :q, search_term)
  end

  defp maybe_add_opt(query, :country, %Bite{country: country}) when not is_nil(country) do
    Map.put(query, :country, Atom.to_string(country))
  end

  defp maybe_add_opt(query, :category, %Bite{category: category}) when not is_nil(category) do
    query = Map.put(query, :category, Atom.to_string(category))

    if Map.has_key?(query, :country) do
      query
    else
      Map.put(query, :country, "us")
    end
  end

  defp maybe_add_opt(query, _, _), do: query
end
