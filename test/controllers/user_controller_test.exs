defmodule Mealplanner.UserControllerTest do
    use Mealplanner.ConnCase

    setup do
        user = Repo.insert!( User.registration_changeset(%User{}, %{ name: "user", email: "abc@gmail.com", password: "12345678" }) )
        conn = guardian_login(build_conn(), user)
        {:ok, conn: conn}
    end

    describe "new" do
        test "GET /", %{conn: conn} do
            conn = get conn, "/users/new"
            assert html_response(conn, 200)
        end
    end

    describe "create" do
        test "creates a new user when parameters are valid", %{conn: conn} do
            assert Repo.aggregate(User, :count, :id) == 1
            post conn, "/users", %{user: %{ name: "New user", email: "a@b.com", password: "123456789" }}
            assert Repo.aggregate(User, :count, :id) == 2
            assert Repo.get_by(User, name: "New user").email == "a@b.com"
        end

        test "returns errors when data is incorrect or missing", %{conn: conn} do
            conn = post conn, "/users", %{user: %{ name: "New user", email: "", password: "12345678" }}
            assert Keyword.has_key?(conn.assigns[:changeset].errors, :email)
        end
    end
  
end
