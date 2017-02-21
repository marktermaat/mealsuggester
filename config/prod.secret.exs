use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :mealplanner, Mealplanner.Endpoint,
  secret_key_base: "Jwdi1fFI1HOY3DhwwTSukWmIp7aXCMqoHJoNFkE542q8UP8zj6X1Bl3YQqcfLgGy"

# Configure your database
config :mealplanner, Mealplanner.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "mealplanner_prod",
  pool_size: 20
