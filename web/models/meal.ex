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
  A composable query to find a meal by id
  """
  def by_id(query, id) do
      from m in query, where: m.id == ^id
  end

  def by_user_id(query, user_id) do
      from m in query,
        where: m.user_id == ^user_id and
        (is_nil(m.snoozed_until) or m.snoozed_until < ^Timex.now ),
        order_by: [asc: m.latest]
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

  def update_snooze_changeset(struct, params \\ %{}) do
      struct
    |> cast(params, [:snooze_counter, :snoozed_until])
    |> validate_required([:snooze_counter, :snoozed_until])
  end
end
