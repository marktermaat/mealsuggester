defmodule Mealplanner.Router do
  use Mealplanner.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Mealplanner do
    pipe_through :browser # Use the default browser stack

    get "/meals", MealController, :index

    resources "/users", UserController, only: [:new, :create]
  end
end
