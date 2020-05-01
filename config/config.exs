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
config :cashtrail,
  ecto_repos: [Cashtrail.Repo],
  comeonin_hash_module: Argon2

config :triplex, repo: Cashtrail.Repo

config :cashtrail_web,
  ecto_repos: [Cashtrail.Repo],
  generators: [context_app: :cashtrail, binary_id: true]

# Configures the endpoint
config :cashtrail_web, CashtrailWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cpkAN7FBHyu+QSgtMgPeeB4e/VeAOtr9z/J9qynhOmbGoL9r+k1mpgJxMupdb95J",
  render_errors: [view: CashtrailWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Cashtrail.PubSub,
  live_view: [signing_salt: "xsy+inIv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
