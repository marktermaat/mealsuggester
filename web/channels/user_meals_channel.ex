defmodule Mealplanner.UserMealsChannel do
    use Phoenix.Channel

    import Ecto.Query
    alias Mealplanner.Meal
    alias Mealplanner.Repo

    def join( "meals:" <> user_id, _message, socket ) do
        send(self, :send_meals)
        {:ok, socket}
    end

    def handle_in( "new_meal", new_meal, socket ) do
        IO.inspect new_meal
        changeset = Meal.changeset(%Meal{}, new_meal)
        IO.inspect changeset
        IO.puts changeset.valid?
        Repo.insert(changeset)
        send(self, :send_meals)
        # push socket, "new_msg", %{body: "console.log('works!');"}
        {:noreply, socket}
    end

    def handle_info( :send_meals, socket ) do
        all_meals = from m in Meal, order_by: [asc: m.latest]
        mealsRepo = Repo.all(all_meals)
        mealsPartial = get_template( "_meals.html", %{meals: mealsRepo} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    def get_template(name, data \\ %{}) do
        Phoenix.View.render_to_string Mealplanner.MealView, "_meals.html", data
    end
end
