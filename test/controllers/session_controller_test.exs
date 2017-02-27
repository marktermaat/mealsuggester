defmodule Mealplanner.SessionControllerTest do
  use Mealplanner.ConnCase

  alias Mealplanner.User
  alias Mealplanner.Repo

  describe "new" do
      test "GET /", %{conn: conn} do
        conn = get conn, "/sessions/new"
        assert html_response(conn, 200)
    end
  end
end
