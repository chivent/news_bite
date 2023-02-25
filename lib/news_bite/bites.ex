defmodule NewsBite.Bites do
  alias NewsBite.{Articles, Bite, BiteCache}
  alias NewsBite.Utils.{Countries, Summarise}

  defdelegate get_bite_by_id(id), to: BiteCache, as: :get_bite
  defdelegate delete_bite(id), to: BiteCache

  def upsert_bite(%{"id" => ""} = attrs) do
    upsert_bite(%Bite{}, attrs)
  end

  def upsert_bite(%{"id" => id} = attrs) do
    id
    |> get_bite_by_id()
    |> upsert_bite(attrs)
  end

  def upsert_bite_article_groups(%Bite{} = bite) do
    article_groups =
      bite
      |> Articles.get_articles_by_bite()
      |> Articles.articles_into_words()
      |> Summarise.group_by_top_words()

    bite
    |> Bite.article_groups_changeset(%{article_groups: article_groups})
    |> Ecto.Changeset.apply_changes()
  end

  def upsert_bite_article_groups(id) do
    id
    |> get_bite_by_id()
    |> upsert_bite_article_groups()
  end

  def get_bite_title(bite) do
    category =
      if bite.category do
        category = bite.category |> Atom.to_string() |> String.capitalize()
        " for #{category} "
      else
        ""
      end

    country = if bite.country, do: " in #{Countries.get_name_by_code(bite.country)} ", else: ""

    search_terms =
      if length(bite.search_terms) > 0 do
        " with '" <> Enum.join(bite.search_terms, ", ") <> "'"
      else
        ""
      end

    "Latest news" <> country <> category <> search_terms
  end

  defp upsert_bite(bite, attrs) do
    bite
    |> Bite.changeset(attrs)
    |> Ecto.Changeset.apply_changes()
    |> upsert_bite_article_groups()
    |> BiteCache.upsert_bite()
  end
end
