defmodule Mealplanner.MealTest do
    use Mealplanner.ModelCase, async: true

    alias Mealplanner.Meal

    describe "new_meal_changeset" do
        @valid_attrs %{latest: %{day: 17, month: 4, year: 2010}, name: "some content", user_id: 1}
        @invalid_attrs %{}

        test "changeset with valid attributes" do
            changeset = Meal.new_meal_changeset(%Meal{}, @valid_attrs)
            assert changeset.valid?
        end

        test "changeset with invalid attributes" do
            changeset = Meal.new_meal_changeset(%Meal{}, @invalid_attrs)
            refute changeset.valid?
        end

        test "sets the default value for snooze counter" do
            changeset = Meal.new_meal_changeset(%Meal{}, @valid_attrs)
            assert Ecto.Changeset.get_field(changeset, :snooze_counter) == 0
        end
    end
  
end
