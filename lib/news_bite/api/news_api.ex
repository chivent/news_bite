defmodule NewsBite.Api.NewsApi do
  def get_news_list(:mock) do
    filename = Application.app_dir(:news_bite, "priv/static/mock_news_source.json")

    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body) do
      articles =
        json["articles"]
        |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
        |> Enum.into(%{})

      {:ok, articles}
    else
      _ -> {:error}
    end
  end

  def get_news_list(opts) do
    # TODO: Update to actual API call later
    opts
  end

  # def get_bite_summary?
end
