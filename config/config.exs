# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :crowd_pomodoro,
  ecto_repos: [CrowdPomodoro.Repo]

# Configures the endpoint
config :crowd_pomodoro, CrowdPomodoroWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9mL2VS5BSXlY9vPkQN+FfN37oDG/KMiM0qjqrTVd/dJslQLurFqG8nN6VbOcgShS",
  render_errors: [view: CrowdPomodoroWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CrowdPomodoro.PubSub,
  live_view: [signing_salt: "GXgzmvow"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
