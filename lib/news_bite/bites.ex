defmodule NewsBite.Bites do
  alias NewsBite.{Articles, Bite, BiteCache}

  # Add User Id later
  # def get_bites_by_user(user_id) do
  # end
  def get_bite(id), do: BiteCache.get_bite(id)

  def create_bite(attrs) do
    upsert_bite(%Bite{}, attrs)
  end

  @spec update_bite(any, any) :: none
  def update_bite(id, attrs) do
    id
    |> BiteCache.get_bite()
    |> upsert_bite(attrs)
  end

  def delete_bite(id), do: BiteCache.delete_bite(id)

  def get_bite_articles(bite), do: Articles.get_articles(bite)

  def get_bite_search_url(bite) do
    "https://news.google.com/search?q=#{bite.search_term}"
  end

  def get_bite_summary(bite) do
    bite
    |> get_bite_articles()

    # TODO: |> get me the summary.
  end

  defp upsert_bite(bite, attrs) do
    bite
    |> Bite.changeset(attrs)
    |> Ecto.Changeset.apply_changes()
    |> BiteCache.upsert_bite()
  end
end
