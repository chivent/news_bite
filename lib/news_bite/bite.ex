defmodule NewsBite.Bite do
  alias __MODULE__
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:category, Ecto.Enum,
      values: [:business, :entertainment, :general, :health, :science, :sports, :technology]
    )

    field(:country, Ecto.Enum, values: NewsBite.Utils.Countries.enum())
    field(:search_terms, {:array, :string})
    field(:duration_span, :integer)
    field(:duration, Ecto.Enum, values: [:year, :month, :week, :day, :hour])
    field(:article_groups, {:array, :map}, default: nil)

    # These bites are for latest headlines...
    # Article limit as an option 100/200/500, auto-refresh rate as an option every 2/4/6/12 hours. Max 4 bites
  end

  def changeset(struct \\ %Bite{}, attrs) do
    struct
    |> cast(attrs, [:category, :search_terms, :country, :duration, :duration_span])
    |> maybe_generate_uuid()
    |> validate_number(:duration_span, greater_than_or_equal_to: 1)
  end

  def article_groups_changeset(bite, attrs) do
    cast(bite, attrs, [:article_groups])
  end

  defp maybe_generate_uuid(%Ecto.Changeset{data: %Bite{id: id}} = changeset) when not is_nil(id),
    do: changeset

  defp maybe_generate_uuid(changeset),
    do: put_change(changeset, :id, Ecto.UUID.generate())
end
