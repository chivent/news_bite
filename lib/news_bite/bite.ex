defmodule NewsBite.Bite do
  @moduledoc """
  The Bite schema.
  """
  alias __MODULE__
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:category, Ecto.Enum,
      values: [:business, :entertainment, :general, :health, :science, :sports, :technology]
    )

    field(:country, Ecto.Enum, values: NewsBite.Utils.Countries.enum())
    field(:search_term, :string)
    field(:article_groups, {:array, :map}, default: nil)
  end

  @doc """
  Changeset for updating/creating bites
  """
  def changeset(struct \\ %Bite{}, attrs) do
    struct
    |> cast(attrs, [:category, :search_term, :country])
    |> maybe_generate_uuid()
  end

  @doc """
  Changeset for updating article groups
  """
  def article_groups_changeset(bite, attrs) do
    cast(bite, attrs, [:article_groups])
  end

  defp maybe_generate_uuid(%Ecto.Changeset{data: %Bite{id: id}} = changeset) when not is_nil(id),
    do: changeset

  defp maybe_generate_uuid(changeset),
    do: put_change(changeset, :id, Ecto.UUID.generate())
end
