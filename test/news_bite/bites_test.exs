defmodule NewsBite.BitesTest do
  use ExUnit.Case, async: true
  alias NewsBite.{Bite, Bites, BiteCache}

  test "create_bite/1 returns a new bite" do
    start_supervised(BiteCache)

    bite =
      Bites.create_bite(%{"country" => :sg, "category" => :business, "search_term" => "apple"})

    inserted_bite = BiteCache.get_bite(bite.id)
    refute is_nil(inserted_bite)
    assert inserted_bite.country == :sg
    assert inserted_bite.category == :business
    assert inserted_bite.search_term == "apple"
    refute is_nil(inserted_bite.article_groups)
  end

  test "update_bite/1 updates an existing bite" do
    start_supervised(BiteCache)
    BiteCache.upsert_bite(%Bite{id: 1, country: :us})

    bite =
      Bites.update_bite(%{
        "id" => 1,
        "country" => "sg",
        "category" => "business",
        "search_term" => "apple"
      })

    inserted_bite = BiteCache.get_bite(bite.id)
    assert inserted_bite.country == :sg
    assert inserted_bite.category == :business
    assert inserted_bite.search_term == "apple"
    refute is_nil(inserted_bite.article_groups)
  end

  test "update_bite_news/1 updates the article_groups of a bite" do
    start_supervised(BiteCache)
    BiteCache.upsert_bite(%Bite{id: 1, country: :us})

    Bites.update_bite_news(1)

    updated_bite = BiteCache.get_bite(1)
    refute is_nil(updated_bite.article_groups)
  end

  test "get_bite_title/1 builds a title for the bite" do
    bite = %Bite{country: :sg, category: :business, search_term: "apple"}
    assert "Latest news in Singapore  for Business  with 'apple'" == Bites.get_bite_title(bite)
  end
end
