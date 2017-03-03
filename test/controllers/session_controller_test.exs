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

  describe "create" do
      test "logs user in with correct password", %{conn: conn} do
          {:ok, user} = Repo.insert( User.registration_changeset(%User{}, %{name: "user", email: "ab@cd.com", password: "12345678"}) )
          conn = post conn, "/sessions", %{ session: %{ email: "ab@cd.com", password: "12345678" } }
          assert Guardian.Plug.current_resource(conn).id == user.id
      end

      test "does not log in user with incorrect email", %{conn: conn} do
          Repo.insert( User.registration_changeset(%User{}, %{name: "user", email: "ab@cd.com", password: "12345678"}) )
          conn = post conn, "/sessions", %{ session: %{ email: "abb@cd.com", password: "12345678" } }
          assert Guardian.Plug.current_resource(conn) == nil
      end

      test "does not log in user with incorrect password", %{conn: conn} do
          Repo.insert( User.registration_changeset(%User{}, %{name: "user", email: "ab@cd.com", password: "12345678"}) )
          conn = post conn, "/sessions", %{ session: %{ email: "ab@cd.com", password: "123456789" } }
          assert Guardian.Plug.current_resource(conn) == nil
      end
  end
end
