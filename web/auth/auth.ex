defmodule Mealplanner.Auth do
    import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

    def login_user(conn, user, password) do
        cond do
            user && checkpw(password, user.password_hash) ->
                {:ok, login(conn, user)}
            
            user ->
                {:error, :unauthorized, conn}
            
            true ->
                # simulate check password hash timing
                dummy_checkpw
                {:error, :not_found, conn}
        end
    end

    def logout_user(conn) do
        logout(conn)
    end

    defp login(conn, user) do
        Guardian.Plug.sign_in(conn, user)
    end

    defp logout(conn) do
        Guardian.Plug.sign_out(conn)
    end
end