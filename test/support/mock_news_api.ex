defmodule NewsBite.Api.MockNewsApi do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/everything" do
    case conn.params do
      %{"q" => "failure:" <> error_code} ->
        failure(conn, error_code |> wrap_error_response())

      _ ->
        success(conn, get_news(conn.params, :everything) |> wrap_success_response())
    end
  end

  get "/top-headlines" do
    case conn.params do
      %{"q" => "failure:" <> error_code} ->
        failure(conn, error_code |> wrap_error_response())

      _ ->
        success(conn, get_news(conn.params, :top_headlines) |> wrap_success_response())
    end
  end

  def article_template(title) do
    %{
      "title" => "This is a #{title} title",
      "description" => "This is a #{title} description",
      "url" => "https://localhost:8000/article_1",
      "publishedAt" => "2023-01-27T12:00:27Z"
    }
  end

  defp success(conn, body \\ "") do
    conn
    |> Plug.Conn.send_resp(200, Jason.encode!(body))
  end

  defp failure(conn, error_code) do
    conn
    |> Plug.Conn.send_resp(500, Jason.encode!(error_code))
  end

  defp get_news(params, origin) do
    params
    |> Map.take(["country", "category", "q"])
    |> Map.put("origin", Atom.to_string(origin))
    |> Map.values()
    |> get_articles(Map.get(params, "q"))
  end

  defp get_articles(type_list, "x2") do
    title = Enum.join(type_list, " ")

    [article_template(title), article_template(title <> "2")]
  end

  defp get_articles(type_list, _) do
    title = Enum.join(type_list, " ")

    [article_template(title)]
  end

  defp wrap_success_response(articles) do
    %{
      "status" => "ok",
      "totalResults" => length(articles),
      "articles" => articles
    }
  end

  defp wrap_error_response(code), do: %{"code" => code}
end
