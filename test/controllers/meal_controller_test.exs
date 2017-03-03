defmodule Mealplanner.MealControllerTest do
    use Mealplanner.ConnCase, async: true

    setup do
        user = Repo.insert!( User.registration_changeset(%User{}, %{ name: "user", email: "abc@gmail.com", password: "12345678" }) )
        conn = guardian_login(build_conn(), user)
        {:ok, conn: conn}
    end

    test "GET /", %{conn: conn} do
        conn = get conn, "/"
        assert html_response(conn, 200)
    end
end
