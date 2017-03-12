# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mealplanner,
  ecto_repos: [Mealplanner.Repo]

# Configures the endpoint
config :mealplanner, Mealplanner.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sb5ShrWr+pFGl1sygyIWAh9o5jzwLsbQAPCaWjLKhzesujwN+IAEJy157HNFGHrU",
  check_origin: ["//localhost", "//127.0.0.1", "//ter-maat.com", "//192.168.2.4"],
  render_errors: [view: Mealplanner.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mealplanner.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "Mealplanner.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  serializer: Mealplanner.GuardianSerializer,
  secret_key: to_string(Mix.env) <> "SuPerseCret_aBraCadabrA"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
