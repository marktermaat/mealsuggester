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
        case Repo.get_by(Meal, name: Map.fetch!(new_meal, "name")) do
            nil -> %Meal{}
            meal -> meal
        end
        |> Meal.changeset(new_meal)
        |> Repo.insert_or_update
        send(self, :send_meals)

        alert_partial = get_template( "_new_meal_ok.html" )
        push socket, "html", %{".server-alert": alert_partial}
        {:noreply, socket}
    end

    def handle_info( :send_meals, socket ) do
        all_meals_query = from m in Meal, order_by: [asc: m.latest]
        meals = Repo.all(all_meals_query)
        mealsPartial = get_template( "_meals.html", %{meals: meals} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    def get_template(name, data \\ %{}) do
        Phoenix.View.render_to_string Mealplanner.MealView, name, data
    end
end
