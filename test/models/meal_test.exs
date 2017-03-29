defmodule Mealplanner.MealTest do
  use Mealplanner.ModelCase, async: true

  alias Mealplanner.Meal

  @valid_attrs %{latest: %{day: 17, month: 4, year: 2010}, name: "some content", user_id: 1, snoozed_until: %{day: 17, month: 4, year: 2010, hour: 10, minute: 10, second: 10}, snooze_counter: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Meal.changeset(%Meal{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Meal.changeset(%Meal{}, @invalid_attrs)
    refute changeset.valid?
  end
end
