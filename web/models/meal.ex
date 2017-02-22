defmodule Mealplanner.Meal do
  use Mealplanner.Web, :model

  schema "meals" do
    field :name, :string
    field :latest, Timex.Ecto.Date

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :latest])
    |> validate_required([:name, :latest])
  end
end
