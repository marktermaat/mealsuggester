defmodule Mealplanner.Repo.Migrations.AddSnoozingToMeals do
  use Ecto.Migration

  def change do
    alter table(:meals) do
        add :snoozed_until, :utc_datetime
        add :snooze_counter, :integer
    end
  end
end
