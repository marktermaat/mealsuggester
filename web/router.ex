defmodule Mealplanner.Router do
  use Mealplanner.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :with_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Mealplanner.CurrentUser
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated, handler: Mealplanner.GuardianErrorHandler
  end

  scope "/mealtracker" do
    scope "/", Mealplanner do
      pipe_through [:browser, :with_session] # Use the default browser stack

      resources "/sessions", SessionController, only: [:new, :create, :delete]
      resources "/users", UserController, only: [:new, :create]
    end

    # Restricted zone
    scope "/", Mealplanner do
      pipe_through [:browser, :with_session, :login_required] # Use the default browser stack

      get "/", MealController, :index
    end
  end
end
