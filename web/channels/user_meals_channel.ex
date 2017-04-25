defmodule Mealplanner.UserMealsChannel do
    use Mealplanner.Web, :channel
    use Phoenix.Channel
    import Guardian.Phoenix.Socket

    def join( "meals:" <> user_id, _params, socket ) do
        user = current_resource(socket)
        case String.to_integer(user_id) == user.id do
            true ->
                send(self(), :send_meals)
                {:ok, socket}
            false ->
                {:error, :unauthorized}
        end
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

    def handle_in( "show_meals", input, socket ) do
        send(self(), {:send_meals, input})
        {:noreply, socket}
    end

    def handle_in( "snooze_meal", %{ "id" => id }, socket ) do
        send(self(), {:snooze_meal, id})
        {:noreply, socket}
    end

    def handle_info( :send_meals, socket ) do
        user = current_resource(socket)
        all_meals_query = Meal.by_user_id(Meal, user.id)
        meals = Repo.all(all_meals_query)
        mealsPartial = get_template( "_meals.html", %{meals: meals} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    def handle_info( {:send_meals, search_terms}, socket ) do
        user = current_resource(socket)
        terms = split_search_terms(search_terms)

        all_meals_query = Meal.by_user_id(Meal, user.id)
        all_meals_query = Enum.reduce(terms, all_meals_query, fn(term, query) -> from q in query, where: ilike(q.name, ^term) end)

        meals = Repo.all(all_meals_query)
        mealsPartial = get_template( "_meals.html", %{meals: meals} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    def handle_info( {:snooze_meal, id}, socket ) do
        meal = Meal
            |> Meal.by_id(id)
            |> Repo.one
            # Filter by user_id too!
        
        snooze_counter = (meal.snooze_counter || 0) + 1
        snooze_date = get_new_snooze_date(meal.snooze_counter)
        changeset = Meal.update_snooze_changeset(meal, %{snooze_counter: snooze_counter, snoozed_until: snooze_date})
        result = Repo.update(changeset)
        
        send(self(), :send_meals)
        {:noreply, socket}
    end

    # ============ Private helpers ========================

    defp split_search_terms( %{} ) do
        []
    end
    defp split_search_terms( search_terms ) do
        search_terms
            |> String.split(" ")
            |> Stream.map( fn(term) -> String.replace(term, ~r/\W/, "") end )
            |> Stream.map( &String.downcase/1 )
            |> Stream.map( fn(term) -> "%" <> term <> "%" end )
            |> Enum.to_list
    end

    defp get_template(name, data \\ %{}) do
        Phoenix.View.render_to_string Mealplanner.MealView, name, data
    end

    defp upsert_meal( new_meal, user ) do
        case Repo.one(from m in Meal, where: m.user_id == ^user.id and ilike(m.name, ^Map.fetch!(new_meal, "name"))) do
            nil -> %Meal{user_id: user.id}
            meal -> meal
        end
        |> Meal.new_meal_changeset(new_meal)
        |> Repo.insert_or_update
    end

    defp get_new_snooze_date( nil ) do
        Timex.shift(Timex.now, days: 7)
    end

    defp get_new_snooze_date( 0 ) do
        Timex.shift(Timex.now, days: 7)
    end

    defp get_new_snooze_date( 1 ) do
        Timex.shift(Timex.now, days: 14)
    end

    defp get_new_snooze_date( 2 ) do
        Timex.shift(Timex.now, days: 14)
    end

    defp get_new_snooze_date( _ ) do
        Timex.shift(Timex.now, days: 28)
    end
end
