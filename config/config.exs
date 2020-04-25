# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :cashtray,
  ecto_repos: [Cashtray.Repo]

config :triplex, repo: Cashtray.Repo

config :cashtray_web,
  ecto_repos: [Cashtray.Repo],
  generators: [context_app: :cashtray, binary_id: true]

# Configures the endpoint
config :cashtray_web, CashtrayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jydE81XIaJHivGGMzMWS9kfti9I+32DZr1iu6c7hUyLXJcMSpiAdIC/qlQNtfFhI",
  render_errors: [view: CashtrayWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: CashtrayWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "ACa82eR2"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
