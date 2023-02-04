defmodule NewsBite.Api.NewsApi do
  alias NewsBite.Utils

  def get_news_list(:mock) do
    filename = Application.app_dir(:news_bite, "priv/static/mock_news_source.json")

    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body) do
      {:ok, Utils.atomize_map_keys(json["articles"])}
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
