defmodule Cashtray.Repo do
  use Ecto.Repo,
    otp_app: :cashtray,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20
end
