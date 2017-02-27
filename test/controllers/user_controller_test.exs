defmodule Mealplanner.UserControllerTest do
  use Mealplanner.ConnCase

  alias Mealplanner.User
  alias Mealplanner.Repo

  describe "new" do
      test "GET /", %{conn: conn} do
        conn = get conn, "/users/new"
        assert html_response(conn, 200)
    end
  end

  describe "create" do
      test "creates a new user when parameters are valid", %{conn: conn} do
          assert Repo.aggregate(User, :count, :id) == 0
          post conn, "/users", %{user: %{ name: "New user", email: "a@b.com", password: "12345678" }}
          assert Repo.aggregate(User, :count, :id) == 1
          assert Repo.get_by(User, name: "New user").email == "a@b.com"
      end

      test "returns errors when data is incorrect or missing", %{conn: conn} do
          conn = post conn, "/users", %{user: %{ name: "New user", email: "", password: "12345678" }}
          assert Keyword.has_key?(conn.assigns[:changeset].errors, :email)
      end
  end
  
end
