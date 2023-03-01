defmodule NewsBite.Api.NewsApi do
  alias NewsBite.{Bite, Utils}

  @api_key Application.compile_env(:news_bite, :news_api_key)

  def get_news_list(:mock) do
    filename = Application.app_dir(:news_bite, "priv/static/mock_news_source.json")

    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body) do
      {:ok, Utils.atomize_map_keys(json["articles"])}
    else
      _ -> {:api_error, "News not retrieved"}
    end
  end

  def get_news_list(bite) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Api-Key", @api_key}
    ]

    request = build_request(bite)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(request, headers),
         {:ok, json} <- Jason.decode(body) do
      {:ok, Utils.atomize_map_keys(json["articles"])}
    else
      {:error, %HTTPoison.Response{body: body}} ->
        {:ok, json} = Jason.decode(body)
        translate_error_message(json["code"])
    end
  end

  defp build_request(bite) do
    url =
      if Map.get(bite, :country) == nil && Map.get(bite, :category) == nil do
        "https://newsapi.org/v2/everything"
      else
        "https://newsapi.org/v2/top-headlines"
      end

    url
    |> URI.parse()
    |> build_query(bite)
    |> URI.to_string()
  end

  defp build_query(url, %Bite{} = bite) do
    query =
      %{}
      |> maybe_add_opt(:search_term, bite)
      |> maybe_add_opt(:country, bite)
      |> maybe_add_opt(:category, bite)
      |> maybe_add_opt(:language, bite)
      |> Map.put("pageSize", 100)
      |> URI.encode_query()

    Map.put(url, :query, query)
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

  defp maybe_add_opt(query, :language, %Bite{country: nil, category: nil}) do
    Map.put(query, :language, "en")
  end

  defp maybe_add_opt(query, _, _), do: query

  defp translate_error_message(code) do
    case code do
      "apiKeyDisabled" ->
        {:api_error, "an error has arisen in the service key, please contact the developer."}

      "apiKeyExhausted" ->
        {:api_error, "the Bite refresh limit has been reached for the day."}

      "rateLimited" ->
        {:api_error,
         "too many refreshes have been made in a short period of time. Please wait a bit before trying again."}

      _ ->
        {:api_error, "an error occured."}
    end
  end
end
