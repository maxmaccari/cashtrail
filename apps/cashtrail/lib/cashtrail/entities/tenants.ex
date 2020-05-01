defmodule Cashtrail.Entities.Tenants do
  alias Cashtrail.Entities.Entity

  @moduledoc """
  Deal with tenants creation for Entity.

  Every created Entity should be a tenant and have it's own data. Tenants are
  schemas in the postgres having the data related to Entity.
  """

  @doc """
  Create a tenant for the given Entity.

  See `Triplex.create/2` docs for more information.
  """
  @spec create(%Cashtrail.Entities.Entity{id: Ecto.UUID.t()}) ::
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
  @spec drop(%Cashtrail.Entities.Entity{id: Ecto.UUID.t()}) ::
          {:error, String.t()} | {:ok, Ecto.UUID.t()}
  def drop(%Entity{} = entity) do
    entity
    |> Triplex.to_prefix()
    |> Triplex.drop()
  end

  @doc """
  Return the prefix from Entity.

  See `Triplex.to_prefix/1` docs for more information.
  """
  @spec to_prefix(Cashtrail.Entities.Entity.t()) :: String.t()
  def to_prefix(%Entity{} = entity) do
    Triplex.to_prefix(entity)
  end

  @doc """
  Put ecto prefix in a queryable.

  See `Triplex.to_prefix/1` docs for more information.
  """
  @spec put_prefix(Ecto.Queryable.t(), Cashtrail.Entities.Entity.t()) :: Ecto.Query.t()
  def put_prefix(queryable, %Entity{} = entity) do
    queryable
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
  end
end
