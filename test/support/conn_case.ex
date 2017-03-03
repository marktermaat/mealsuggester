defmodule Mealplanner.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Mealplanner.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias Mealplanner.User

      import Mealplanner.Router.Helpers

      # The default endpoint for testing
      @endpoint Mealplanner.Endpoint

      @secret String.duplicate("abcdef0123456789", 8)
      @signing_opts Plug.Session.init([{:encrypt, false}, {:store, :cookie}, {:key, "mykey"}, {:signing_salt, "salt"}])

      # We need a way to get into the connection to login a user
      # We need to use the bypass_through to fire the plugs in the router
      # and get the session fetched.
      def guardian_login(conn, user, token \\ :token, perms \\ %{default: Guardian.Permissions.max}) do
        conn = put_in(conn.secret_key_base, @secret)
          |> Plug.Session.call(@signing_opts)
          |> Plug.Conn.fetch_session
          |> Guardian.Plug.sign_in(user, token, perms: perms)
          |> Guardian.Plug.VerifySession.call(%{})
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Mealplanner.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Mealplanner.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
