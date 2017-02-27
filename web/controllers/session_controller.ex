defmodule Mealplanner.SessionController do
    use Mealplanner.Web, :controller

    plug :scrub_params, "session" when action in [:create]

    def new(conn, _) do
        render conn, "new.html"
    end

    def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
        # here will be an implementation
    end

    def delete(conn, _) do
        # here will be an implementation
    end
end