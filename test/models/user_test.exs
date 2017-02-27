defmodule Mealplanner.UserTest do
  use Mealplanner.ModelCase, async: true

  alias Mealplanner.User

  @valid_attrs %{email: "myemail@mail.com", name: "some content", password: "some content"}
  @invalid_attrs %{}

  describe "validations" do
    test "changeset with valid attributes" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = User.changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with invalid email" do
      changeset = User.changeset(%User{}, Map.put(@valid_attrs, :email, "myemail@mail"))
      refute changeset.valid?
    end

    test "minimum length name" do
      changeset = User.changeset(%User{}, Map.put(@valid_attrs, :name, "."))
      refute changeset.valid?
    end

    test "minimum length password" do
      changeset = User.changeset(%User{}, Map.put(@valid_attrs, :password, "1234567"))
      refute changeset.valid?
    end
  end

  describe "password hashing" do
    test "sets password_hash when changeset is valid" do
      changeset = User.registration_changeset(%User{}, @valid_attrs)
      refute Ecto.Changeset.get_change(changeset, :password_hash) == nil
    end

    test "does not set password_hash when changeset is not valid" do
      changeset = User.registration_changeset(%User{}, @invalid_attrs)
      assert Ecto.Changeset.get_change(changeset, :password_hash) == nil
    end
  end

  
end
