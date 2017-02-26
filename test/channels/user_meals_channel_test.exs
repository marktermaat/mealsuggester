defmodule Mealplanner.Channel.UserMealsChannelTest do
    use Mealplanner.ChannelCase

    alias Mealplanner.UserMealsChannel
    alias Mealplanner.Meal
    alias Mealplanner.Repo

    describe "join channel" do
        setup do
            socket = socket()
            {:ok, socket: socket}
        end

        test "returns ok", %{socket: socket} do
            {:ok, _reply, _socket} = subscribe_and_join(socket, UserMealsChannel, "meals:1")
        end

        test "sends html with data for meals", %{socket: socket} do
            subscribe_and_join(socket, UserMealsChannel, "meals:1")
            assert_push "html", %{".server-meals": _}
        end

        test "sends correct meals", %{socket: socket} do
            create_meals()

            subscribe_and_join(socket, UserMealsChannel, "meals:1")
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            assert data =~ "Rice"
        end
    end

    describe "new_meal" do
        setup do
            create_meals()
            {:ok, _, socket} = socket()
                |> subscribe_and_join(UserMealsChannel, "meals:1")
            assert_push "html", %{".server-meals": _}

            {:ok, socket: socket}
        end

        test "receives an updated list with meals", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: to_string(Timex.today)}
            
            assert_push "html", %{".server-meals": data}
            assert data =~ "Pasta"
            assert data =~ "Rice"
            assert data =~ "Lasagna"
        end

        test "receives an alert with everything whent ok", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: to_string(Timex.today)}
            assert_push "html", %{".server-alert": data}
            assert data =~ "successfully"
        end

        test "does not send meal data when the new meal is not valid", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: "whatsthis?"}
            refute_push "html", %{".server-meals": _}
        end

        test "sends an alert when the new meal is not valid", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: "whatsthis?"}
            assert_push "html", %{".server-alert": data}
            assert data =~ "error"
        end

        test "it inserts a new meal into the database", %{socket: socket} do
            push socket, "new_meal", %{name: "Lasagna", latest: to_string(Timex.today)}
            assert_push "html", %{".server-alert": _}
            assert Repo.aggregate(Meal, :count, :id) == 3
            assert Repo.get_by(Meal, name: "Lasagna").latest == Timex.today
        end

        test "it updates an existing meal if found", %{socket: socket} do
            push socket, "new_meal", %{name: "Pasta", latest: to_string(Timex.today)}
            assert_push "html", %{".server-alert": _}
            assert Repo.aggregate(Meal, :count, :id) == 2
            assert Repo.get_by(Meal, name: "Pasta").latest == Timex.today
        end

        test "it updates an existing meal if the case if different", %{socket: socket} do
            push socket, "new_meal", %{name: "pasta", latest: to_string(Timex.today)}
            assert_push "html", %{".server-alert": _}
            assert Repo.aggregate(Meal, :count, :id) == 2
            assert Repo.get_by(Meal, name: "pasta").latest == Timex.today
        end
    end

    defp create_meals do
        meals = [
            Meal.changeset(%Meal{}, %{name: "Pasta", latest: Timex.shift(Timex.now, days: 2)}),
            Meal.changeset(%Meal{}, %{name: "Rice", latest: Timex.shift(Timex.now, days: 1)})
        ]

        Enum.each(meals, &Repo.insert!(&1))
    end
    
end