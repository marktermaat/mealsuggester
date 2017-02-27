defmodule Mealplanner.MealControllerTest do
  use Mealplanner.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200)
  end
end
