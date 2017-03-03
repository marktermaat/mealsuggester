defmodule Mealplanner.UserMealsChannel do
    use Mealplanner.Web, :channel
    use Phoenix.Channel
    import Guardian.Phoenix.Socket

    def join( "meals", %{"guardian_token" => token}, socket ) do
        case sign_in(socket, token) do
            {:ok, _authed_socket, _guardian_params} ->
                send(self(), :send_meals)
                {:ok, socket}
            {:error, reason} ->
                {:error, reason}
        end
    end

    def join(_room, %{"guardian_token" => token}, _socket) do
        {:error,  :unknown_channel}
    end

    def join(_room, _, _socket) do
        {:error,  :authentication_required}
    end

    def handle_in( "new_meal", new_meal, socket ) do
        case upsert_meal(new_meal) do
            {:ok, _struct} ->
                send(self(), :send_meals)
                alert_partial = get_template( "_new_meal_ok.html" )
                push socket, "html", %{".server-alert": alert_partial}
            {:error, changeset} ->
                alert_partial = get_template( "_new_meal_error.html", %{changeset: changeset} )
                push socket, "html", %{".server-alert": alert_partial}
        end
        {:noreply, socket}
    end

    def handle_info( :send_meals, socket ) do
        all_meals_query = from m in Meal, order_by: [asc: m.latest]
        meals = Repo.all(all_meals_query)
        mealsPartial = get_template( "_meals.html", %{meals: meals} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    # ============ Private helpers ========================

    defp get_template(name, data \\ %{}) do
        Phoenix.View.render_to_string Mealplanner.MealView, name, data
    end

    defp upsert_meal( new_meal ) do
        case Repo.one(from m in Meal, where: ilike(m.name, ^Map.fetch!(new_meal, "name"))) do
            nil -> %Meal{}
            meal -> meal
        end
        |> Meal.changeset(new_meal)
        |> Repo.insert_or_update
    end
end
