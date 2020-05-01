defmodule Cashtrail.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Cashtrail.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Cashtrail.PubSub}
      # Start a worker by calling: Cashtrail.Worker.start_link(arg)
      # {Cashtrail.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Cashtrail.Supervisor)
  end
end
