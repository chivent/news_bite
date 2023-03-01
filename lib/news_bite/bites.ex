defmodule NewsBite.Bites do
  alias NewsBite.{Articles, Bite, BiteCache}
  alias NewsBite.Utils.Countries

  defdelegate get_bite_by_id(id), to: BiteCache, as: :get_bite
  defdelegate delete_bite(id), to: BiteCache

  def create_bite(attrs) do
    %Bite{}
    |> upsert_bite(attrs)
    |> BiteCache.upsert_bite()
  end

  def update_bite(%{"id" => id} = attrs) do
    id
    |> get_bite_by_id()
    |> upsert_bite(attrs)
    |> BiteCache.upsert_bite()
  end

  def update_bite_news(id) do
    result =
      id
      |> get_bite_by_id()
      |> upsert_bite_article_groups()

    if match?(%Bite{}, result), do: BiteCache.upsert_bite(result)
    result
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
    search_term = if bite.search_term, do: " with '#{bite.search_term}'", else: ""

    "Latest news" <> country <> category <> search_term
  end

  defp upsert_bite({:error, :not_found}, _) do
    {:error, :not_found}
  end

  defp upsert_bite(bite, attrs) do
    bite
    |> Bite.changeset(attrs)
    |> Ecto.Changeset.apply_changes()
    |> upsert_bite_article_groups()
  end

  defp upsert_bite_article_groups(%Bite{} = bite) do
    with article_groups when is_list(article_groups) <- Articles.get_article_groups(bite) do
      bite
      |> Bite.article_groups_changeset(%{article_groups: article_groups})
      |> Ecto.Changeset.apply_changes()
    else
      {:api_error, reason} -> {:api_error, bite, reason}
    end
  end
end
