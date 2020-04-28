defmodule Cashtray.TenantCase do
  @moduledoc """
  DataCase that creates and pass the tenats context for schemas that are created
  inside a tenant.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      use Cashtray.DataCase

      setup_all do
        Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

        uuid = Ecto.UUID.generate()
        tenant = %Cashtray.Entities.Entity{id: uuid}

        Cashtray.Entities.Tenants.create(tenant)

        on_exit(fn ->
          Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

          Cashtray.Entities.Tenants.drop(tenant)

          Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :manual)
        end)

        Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :manual)

        {:ok, [tenant: tenant]}
      end
    end
  end
end
