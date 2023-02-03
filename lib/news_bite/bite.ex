defmodule NewsBite.Bite do
  alias __MODULE__
  import Ecto.Changeset
  use Ecto.Schema
  @article_limits [50, 100, 250, 500, 1000]

  embedded_schema do
    field :subjects, {:array, :string}
    field :search_term, {:array, :string}
    field :duration_span, :integer
    field :article_limit, :integer
    field :duration, Ecto.Enum, values: [:year, :month, :week, :day, :hour]
  end

  def changeset(struct \\ %Bite{}, attrs) do
    struct
    |> cast(attrs, [:subjects, :search_term, :article_limit, :duration, :duration_span])
    |> maybe_generate_uuid()
    |> validate_inclusion(:article_limit, @article_limits)
    |> validate_number(:duration_span, greater_than_or_equal_to: 1)
  end

  defp maybe_generate_uuid(%Ecto.Changeset{data: %Bite{id: id}} = changeset) when not is_nil(id),
    do: changeset

  defp maybe_generate_uuid(changeset),
    do: put_change(changeset, :id, Ecto.UUID.generate())
end
