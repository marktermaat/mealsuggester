defmodule Mealplanner.GuardianErrorHandler do
    import Mealplanner.Router.Helpers

    def unauthenticated(conn, _params) do
        Phoenix.Controller.redirect(conn, to: session_path(conn, :new))
    end
end