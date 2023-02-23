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
    |> get_bite_by_id()
    |> upsert_bite(attrs)
  end

  def upsert_bite_article_groups(bite) do
    article_groups =
      bite
      |> Articles.get_articles_by_bite()
      |> Articles.articles_into_words()
      |> Summarise.group_by_top_words()

    bite
    |> Bite.article_groups_changeset(%{article_groups: article_groups})
    |> Ecto.Changeset.apply_changes()
  end

  def get_bite_search_url(bite) do
    "https://news.google.com/search?q=#{bite.search_term}"
  end

  defp upsert_bite(bite, attrs) do
    bite
    |> Bite.changeset(attrs)
    |> Ecto.Changeset.apply_changes()
    |> upsert_bite_article_groups()
    |> BiteCache.upsert_bite()
  end
end
