defmodule Mealplanner.User do
  use Mealplanner.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password, :password_hash])
    |> validate_required([:name, :email, :password])
    |> validate_length(:name, min: 2)
    |> validate_length(:password, min: 8)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
  end

  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:name, :email, :password, :password_hash])
    |> hash_password
  end

  def hash_password(changeset = %Ecto.Changeset{valid?: true, changes: %{password: password}}) do
    put_change changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password)
  end
  def hash_password(changeset) do changeset end
end
