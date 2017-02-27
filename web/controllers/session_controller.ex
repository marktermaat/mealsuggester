defmodule Mealplanner.SessionController do
    use Mealplanner.Web, :controller

    import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
    
    alias Mealplanner.User

    plug :scrub_params, "session" when action in [:create]

    def new(conn, _) do
        render conn, "new.html"
    end

    def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
        # try to get user by unique email from DB
        user = Repo.get_by(User, email: email)

        # examine the result
        result = cond do
            # if user was found and provided password hash equals to stored hash
            user && checkpw(password, user.password_hash) ->
                {:ok, login(conn, user)}
            
            # else if we just found the user
            user ->
                {:error, :unauthorized, conn}
            
            # otherwise
            true ->
                # simulate check password hash timing
                dummy_checkpw
                {:error, :not_found, conn}
        end

        case result do
            {:ok, conn} -> redirect(conn, to: meal_path(conn, :index))
            {:error, _reason, conn} -> render(conn, "new.html")
        end
    end

    def delete(conn, _) do
        conn
        |> logout
        |> redirect(to: meal_path(conn, :index))
    end

    defp login(conn, user) do
        Guardian.Plug.sign_in(conn, user)
    end

    defp logout(conn) do
        Guardian.Plug.sign_out(conn)
    end
end