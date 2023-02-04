defmodule NewsBite.Bites do
  alias NewsBite.{Articles, Bite, BiteCache}
  alias NewsBite.Utils.Summarise

  def get_bite(id), do: BiteCache.get_bite(id)

  def create_bite(attrs) do
    upsert_bite(%Bite{}, attrs)
  end

  def update_bite(id, attrs) do
    id
    |> BiteCache.get_bite()
    |> upsert_bite(attrs)
  end

  def delete_bite(id), do: BiteCache.delete_bite(id)

  def get_bite_articles(bite), do: Articles.get_articles(bite)

  def get_bite_summary(bite) do
    bite
    |> get_bite_articles()
    |> Summarise.articles_to_key_words()
    |> Enum.take(10)
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
