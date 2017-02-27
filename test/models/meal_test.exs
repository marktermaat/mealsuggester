defmodule Mealplanner.MealTest do
  use Mealplanner.ModelCase, async: true

  alias Mealplanner.Meal

  @valid_attrs %{latest: %{day: 17, month: 4, year: 2010}, name: "some content"}
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
