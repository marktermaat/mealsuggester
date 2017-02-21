defmodule Mealplanner.UserMealsChannel do
    use Phoenix.Channel

    alias Mealplanner.Meal

    def join( "meals:" <> user_id, _message, socket ) do
        send(self, :after_join)
        {:ok, socket}
    end

    def handle_in( "new_msg", %{}, socket ) do
        push socket, "new_msg", %{body: "console.log('works!');"}
        {:noreply, socket}
    end

    def handle_info( :after_join, socket ) do
        meals = [
            %{name: 'Chicken noodles', latest: elem(DateTime.from_iso8601("2015-01-23T23:50:07Z"), 1)},
            %{name: 'Tomato soup', latest: elem(DateTime.from_iso8601("2016-01-23T23:50:07Z"), 1)},
            %{name: 'Lasagna', latest: elem(DateTime.from_iso8601("2017-01-23T23:50:07Z"), 1)}
        ]
        mealsRepo = Mealplanner.Repo.all(Meal)
        IO.inspect(mealsRepo)
        mealsPartial = get_template( "_meals.html", %{meals: mealsRepo} )
        push socket, "html", %{".server-meals": mealsPartial}
        {:noreply, socket}
    end

    def get_template(name, data \\ %{}) do
        Phoenix.View.render_to_string Mealplanner.MealView, "_meals.html", data
    end
end
