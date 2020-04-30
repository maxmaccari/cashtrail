defmodule Cashtray.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Cashtray.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Cashtray.PubSub}
      # Start a worker by calling: Cashtray.Worker.start_link(arg)
      # {Cashtray.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Cashtray.Supervisor)
  end
end
