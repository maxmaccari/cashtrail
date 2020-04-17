defmodule Cashtray.Repo do
  use Ecto.Repo,
    otp_app: :cashtray,
    adapter: Ecto.Adapters.Postgres
end
