defmodule Mealplanner.Meal do
  use Mealplanner.Web, :model

  schema "meals" do
    field :name, :string
    field :latest, Timex.Ecto.Date
    belongs_to :user, Mealplanner.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :latest, :user_id])
    |> validate_required([:name, :latest, :user_id])
  end
end
