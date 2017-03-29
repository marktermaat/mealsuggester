defmodule Mealplanner.Meal do
  use Mealplanner.Web, :model

  schema "meals" do
    field :name, :string
    field :latest, Timex.Ecto.Date
    belongs_to :user, Mealplanner.User
    field :snoozed_until, Timex.Ecto.DateTime
    field :snooze_counter, :integer, default: 0

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :latest, :user_id, :snoozed_until, :snooze_counter])
    |> validate_required([:name, :latest, :user_id])
  end
end
