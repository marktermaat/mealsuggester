defmodule Mealplanner.MealView do
    use Mealplanner.Web, :view

    def errors(changeset) do
        changeset.errors
        |> Enum.map(fn({name, {reason, _}}) -> {name, reason} end)
        |> Enum.into(%{})
        |> Poison.encode!
    end

    def render("scripts.html", _assigns) do
        ~s{<script>window.App.initMeals()</script>}
        |> raw
    end

    def render("title", _assigns) do
      "<span class='title flex-1'>My meals</span>"
      |> raw
    end
end
