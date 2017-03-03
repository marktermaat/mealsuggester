defmodule Mealplanner.ChannelCase do
    @moduledoc """
    This module defines the test case to be used by
    channel tests.

    Such tests rely on `Phoenix.ChannelTest` and also
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
        # Import conveniences for testing with channels
        use Phoenix.ChannelTest

        alias Mealplanner.Repo
        alias Mealplanner.User
        alias Mealplanner.UserMealsChannel

        import Ecto
        import Ecto.Changeset
        import Ecto.Query


        # The default endpoint for testing
        @endpoint Mealplanner.Endpoint

        def user_token() do
            user = Repo.insert!( User.registration_changeset(%User{}, %{ name: "user", email: "abc@gmail.com", password: "12345678" }) )
            {:ok, jwt, _} = Guardian.encode_and_sign(user)
            jwt
        end

        def authorized_channel(channel) do
            jwt = user_token()
            {:ok, _, socket} = socket("authd_socket", %{})
                |> subscribe_and_join( UserMealsChannel, channel, %{"guardian_token" => "#{jwt}"} )
            socket
        end
        end
    end

    setup tags do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Mealplanner.Repo)

        unless tags[:async] do
            Ecto.Adapters.SQL.Sandbox.mode(Mealplanner.Repo, {:shared, self()})
        end

        :ok
    end
end
