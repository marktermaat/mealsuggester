defmodule Mealplanner.Channel.UserMealsChannelTest do
    use Mealplanner.ChannelCase

    alias Mealplanner.UserMealsChannel
    alias Mealplanner.Meal
    alias Mealplanner.Repo

    describe "connect" do
        setup do
            {token, user} = user_token()
            {:ok, token: token, user: user}
        end

        test "returns a socket when using a correct token", %{token: token} do
            {result, socket} = connect(UserSocket, %{"guardian_token" => "#{token}"})
            assert result == :ok
            refute socket == nil
        end
    end

    describe "join channel" do
        setup do
            {socket, user} = connected_socket()
            {:ok, socket: socket, user: user}
        end

        test "returns ok when connecting to correct user channel", %{socket: socket, user: user} do
            {:ok, _reply, _socket} = subscribe_and_join(socket, UserMealsChannel, "meals:#{user.id}", %{})
        end

        test "returns an error when connecting to incorrect user channel", %{socket: socket, user: user} do
            {:error, :unauthorized} = subscribe_and_join(socket, UserMealsChannel, "meals:#{user.id + 1}", %{})
        end

        test "returns errro with incorrect channel", %{socket: socket} do
            {:error, :unknown_channel} = subscribe_and_join(socket, UserMealsChannel, "incorrectchannel", %{})
        end

        test "sends html with data for meals", %{socket: socket, user: user} do
            subscribe_and_join(socket, UserMealsChannel, "meals:#{user.id}", %{})
            assert_push "html", %{".server-meals": _}
        end

        test "sends correct meals", %{socket: socket, user: user} do
            create_meals(user.id)

            subscribe_and_join(socket, UserMealsChannel, "meals:#{user.id}", %{})
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            assert data =~ "Rice"
        end
    end

    describe "new_meal" do
        setup do
            {socket, user} = connected_socket()
            {:ok, _, socket} = subscribe_and_join( socket, UserMealsChannel, "meals:#{user.id}", %{} )
            create_meals(user.id)
            assert_push "html", %{".server-meals": _}

            {:ok, socket: socket}
        end

        test "receives an updated list with meals", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: to_string(Timex.today)}
            
            assert_push "html", %{".server-alert": _}
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            assert data =~ "Rice"
            assert data =~ "Lasagna"
        end

        test "receives an alert with everything whent ok", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: to_string(Timex.today)}

            assert_push "html", %{".server-meals": _}
            assert_push "html", %{".server-alert": data}
            assert data =~ "successfully"
        end

        test "does not send meal data when the new meal is not valid", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: "whatsthis?"}

            assert_push "html", %{".server-alert": _}
            refute_push "html", %{".server-meals": _}
        end

        test "sends an alert when the new meal is not valid", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: "whatsthis?"}
            assert_push "html", %{".server-alert": data}
            assert data =~ "error"
        end

        test "it inserts a new meal into the database", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: to_string(Timex.today)}

            assert_push "html", %{".server-meals": _}
            assert_push "html", %{".server-alert": _}
            assert Repo.aggregate(Meal, :count, :id) == 3
            assert Repo.get_by(Meal, name: "Lasagna").latest == Timex.today
        end

        test "it updates an existing meal if found", %{socket: socket} do
            push socket, "new_meal", %{name: "Pasta", latest: to_string(Timex.today)}

            assert_push "html", %{".server-meals": _}
            assert_push "html", %{".server-alert": _}
            assert Repo.aggregate(Meal, :count, :id) == 2
            assert Repo.get_by(Meal, name: "Pasta").latest == Timex.today
        end

        test "it updates an existing meal if the case if different", %{socket: socket} do
            push socket, "new_meal", %{name: "pasta", latest: to_string(Timex.today)}

            assert_push "html", %{".server-meals": _}
            assert_push "html", %{".server-alert": _}
            assert Repo.aggregate(Meal, :count, :id) == 2
            assert Repo.get_by(Meal, name: "pasta").latest == Timex.today
        end
    end

    describe "filter_meals" do
        setup do
            {socket, user} = connected_socket()
            {:ok, _, socket} = subscribe_and_join( socket, UserMealsChannel, "meals:#{user.id}", %{} )
            create_meals(user.id)
            assert_push "html", %{".server-meals": _}

            {:ok, socket: socket}
        end

        test "it returns all meals when no search terms are send", %{socket: socket} do
            push socket, "show_meals", ""
            
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            assert data =~ "Rice"
        end

        test "filters on a single word", %{socket: socket} do
            push socket, "show_meals", "as"
            
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            refute data =~ "Rice"
        end

        test "filters on multiple words", %{socket: socket} do
            push socket, "show_meals", "as ta"
            
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            refute data =~ "Rice"
        end

        test "filters out special characters", %{socket: socket} do
            push socket, "show_meals", "as.,'-_"
            
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            refute data =~ "Rice"
        end
    end

    describe "snooze_meal" do
        setup do
            {socket, user} = connected_socket()
            {:ok, _, socket} = subscribe_and_join( socket, UserMealsChannel, "meals:#{user.id}", %{} )
            meals = create_meals(user.id)
            assert_push "html", %{".server-meals": _}

            {:ok, socket: socket, meals: meals}
        end

        test "snoozes a meal", %{socket: socket, meals: meals} do
            meal_id = List.first(meals).id
            push socket, "snooze_meal", %{id: meal_id}
            assert_push "html", %{".server-meals": _}
            new_meal = Repo.one(Meal.by_id(Meal, meal_id))
            assert new_meal.snooze_counter == 1
            assert Timex.diff(new_meal.snoozed_until, Timex.shift(Timex.now, days: 7), :seconds) < 1
        end

        test "sends the new meal list", %{socket: socket, meals: meals} do
            push socket, "snooze_meal", %{id: List.first(meals).id}

            assert_push "html", %{".server-meals": data}
            refute data =~ "Pasta"
            assert data =~ "Rice"
        end
    end

    defp create_meals(user_id) do
        meals = [
            Meal.new_meal_changeset(%Meal{}, %{name: "Pasta", user_id: user_id, latest: Timex.shift(Timex.now, days: 2)}),
            Meal.new_meal_changeset(%Meal{}, %{name: "Rice", user_id: user_id, latest: Timex.shift(Timex.now, days: 1)})
        ]

        Enum.map(meals, &Repo.insert!(&1))
    end
    
end