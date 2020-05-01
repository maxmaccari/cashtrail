use Mix.Config

config :cashtrail, comeonin_hash_module: Cashtrail.FakePasswordHash

# Configure your database
config :cashtrail, Cashtrail.Repo,
  username: "postgres",
  password: "postgres",
  database: "cashtrail_test",
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  port: System.get_env("POSTGRES_PORT", "5432") |> String.to_integer(),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cashtrail_web, CashtrailWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
