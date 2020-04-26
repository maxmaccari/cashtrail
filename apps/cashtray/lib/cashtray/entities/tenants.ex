defmodule Cashtray.Entities.Tenants do
  alias Cashtray.Entities.Entity

  @moduledoc """
  Deal with tenants creation for Entity.

  Every created Entity should be a tenant and have it's own data. Tenants are
  schemas in the postgres having the data related to Entity.
  """

  @doc """
  Create a tenant for the given Entity.

  See `Triplex.create/2` docs for more information.
  """
  @spec create(%Cashtray.Entities.Entity{id: Ecto.UUID.t()}) ::
          {:error, String.t()} | {:ok, Ecto.UUID.t()}
  def create(%Entity{} = entity) do
    entity
    |> Triplex.to_prefix()
    |> Triplex.create()
  end

  @doc """
  Drop a tenant for the given Entity.

  See `Triplex.create/2` docs for more information.
  """
  @spec drop(%Cashtray.Entities.Entity{id: Ecto.UUID.t()}) ::
          {:error, String.t()} | {:ok, Ecto.UUID.t()}
  def drop(%Entity{} = entity) do
    entity
    |> Triplex.to_prefix()
    |> Triplex.drop()
  end
end
