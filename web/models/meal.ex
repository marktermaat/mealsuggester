defmodule Mealplanner.Meal do
  use Mealplanner.Web, :model

  schema "meals" do
    field :name, :string
    field :latest, Timex.Ecto.Date
    belongs_to :user, Mealplanner.User
    field :snoozed_until, Timex.Ecto.DateTime
    field :snooze_counter, :integer

    timestamps()
  end

  @doc """
  Builds a changeset to create or update a meal.
  """
  def new_meal_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :latest, :user_id])
    |> validate_required([:name, :latest, :user_id])
    |> put_change(:snooze_counter, 0)
  end
end
