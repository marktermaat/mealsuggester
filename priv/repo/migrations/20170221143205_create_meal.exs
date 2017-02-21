defmodule Mealplanner.Repo.Migrations.CreateMeal do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add :name, :string
      add :latest, :date

      timestamps()
    end

  end
end
