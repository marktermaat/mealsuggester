defmodule Mealplanner.MealController do
  use Mealplanner.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
