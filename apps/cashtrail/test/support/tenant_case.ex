defmodule Cashtrail.TenantCase do
  @moduledoc """
  DataCase that creates and pass the tenats context for schemas that are created
  inside a tenant.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      use Cashtrail.DataCase

      setup_all do
        Ecto.Adapters.SQL.Sandbox.mode(Cashtrail.Repo, :auto)

        uuid = Ecto.UUID.generate()
        tenant = %Cashtrail.Entities.Entity{id: uuid}

        Cashtrail.Entities.Tenants.create(tenant)

        on_exit(fn ->
          Ecto.Adapters.SQL.Sandbox.mode(Cashtrail.Repo, :auto)

          Cashtrail.Entities.Tenants.drop(tenant)

          Ecto.Adapters.SQL.Sandbox.mode(Cashtrail.Repo, :manual)
        end)

        Ecto.Adapters.SQL.Sandbox.mode(Cashtrail.Repo, :manual)

        {:ok, [tenant: tenant]}
      end
    end
  end
end
