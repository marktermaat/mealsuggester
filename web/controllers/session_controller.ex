defmodule Mealplanner.SessionController do
    use Mealplanner.Web, :controller

    alias Mealplanner.User
    alias Mealplanner.Auth

    plug :scrub_params, "session" when action in [:create]

    def new(conn, _) do
        render conn, "new.html"
    end

    def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
        user = Repo.get_by(User, email: email)

        case Auth.login_user(conn, user, password) do
            {:ok, conn} -> redirect(conn, to: meal_path(conn, :index))
            {:error, _reason, conn} -> render(conn, "new.html")
        end
    end

    def delete(conn, _) do
        conn
        |> Auth.logout_user
        |> redirect(to: meal_path(conn, :index))
    end
end