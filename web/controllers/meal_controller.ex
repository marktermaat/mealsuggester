defmodule Mealplanner.MealController do
  use Mealplanner.Web, :controller

  def index(conn, _params) do
    meals = [
      %{name: 'Chicken noodles', last: elem(DateTime.from_iso8601("2015-01-23T23:50:07Z"), 1)},
      %{name: 'Tomato soup', last: elem(DateTime.from_iso8601("2016-01-23T23:50:07Z"), 1)},
      %{name: 'Lasagna', last: elem(DateTime.from_iso8601("2017-01-23T23:50:07Z"), 1)}
    ]
    render conn, "index.html", meals: meals
  end
end
