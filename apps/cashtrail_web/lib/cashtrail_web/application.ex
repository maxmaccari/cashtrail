defmodule CashtrailWeb.Application do
  @moduledoc false

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CashtrailWeb.Telemetry,
      # Start the Endpoint (http/https)
      CashtrailWeb.Endpoint
      # Start a worker by calling: CashtrailWeb.Worker.start_link(arg)
      # {CashtrailWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CashtrailWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CashtrailWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
