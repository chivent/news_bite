defmodule NewsBite.Bites do
  alias NewsBite.{Articles, Bite, BiteCache}
  alias NewsBite.Utils.Summarise

  defdelegate get_bite_by_id(id), to: BiteCache, as: :get_bite
  defdelegate delete_bite(id), to: BiteCache

  # TODO: Return fallback case if none
  def create_bite(attrs) do
    upsert_bite(%Bite{}, attrs)
  end

  # TODO: Return fallback case if error
  def update_bite(id, attrs) do
    id
    # |> get_bite_by_id()
    |> upsert_bite(attrs)
  end

  def generate_bite_summary(bite) do
    bite
    |> Articles.get_articles_by_bite()
    |> Articles.articles_into_words()
    |> Summarise.to_key_words()
  end

  def get_bite_search_url(bite) do
    "https://news.google.com/search?q=#{bite.search_term}"
  end

  defp upsert_bite(bite, attrs) do
    bite
    |> Bite.changeset(attrs)
    |> Ecto.Changeset.apply_changes()
    |> BiteCache.upsert_bite()
  end
end
