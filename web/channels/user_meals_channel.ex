defmodule Mealplanner.UserMealsChannel do
    use Mealplanner.Web, :channel
    use Phoenix.Channel
    import Guardian.Phoenix.Socket

    def join( "meals", _params, socket ) do
        send(self(), :send_meals)
        {:ok, socket}

        # case sign_in(socket, token) do
        #     {:ok, authed_socket, _guardian_params} ->
        #         send(self(), :send_meals)
        #         {:ok, authed_socket}
        #     {:error, reason} ->
        #         {:error, reason}
        # end
    end

    def join(_room, _params, _socket) do
        {:error,  :unknown_channel}
    end

    def handle_in( "new_meal", new_meal, socket ) do
        user = current_resource(socket)
        case upsert_meal(new_meal, user) do
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
        user = current_resource(socket)
        all_meals_query = from m in Meal, where: m.user_id == ^user.id, order_by: [asc: m.latest]
        meals = Repo.all(all_meals_query)
        mealsPartial = get_template( "_meals.html", %{meals: meals} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    # ============ Private helpers ========================

    defp get_template(name, data \\ %{}) do
        Phoenix.View.render_to_string Mealplanner.MealView, name, data
    end

    defp upsert_meal( new_meal, user ) do
        case Repo.one(from m in Meal, where: m.user_id == ^user.id and ilike(m.name, ^Map.fetch!(new_meal, "name"))) do
            nil -> %Meal{user_id: user.id}
            meal -> meal
        end
        |> Meal.changeset(new_meal)
        |> Repo.insert_or_update
    end
end
