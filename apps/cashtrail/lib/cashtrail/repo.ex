defmodule Cashtrail.Repo do
  use Ecto.Repo,
    otp_app: :cashtrail,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20
end
