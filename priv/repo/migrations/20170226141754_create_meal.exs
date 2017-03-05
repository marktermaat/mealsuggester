defmodule Mealplanner.Repo.Migrations.CreateMeal do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add :name, :string
      add :latest, :date
      add :user_id, references(:users)

      timestamps()
    end

    create index(:meals, [:user_id])
  end
end
