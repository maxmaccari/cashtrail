defmodule Cashtrail.Entities.Tenants do
  alias Cashtrail.Entities.Entity

  @moduledoc """
  Deals with tenants creation for Entity.

  Every created Entity should be a tenant and have its data. Tenants are schemas
  in the Postgres having the data related to the Entity.
  """

  @doc """
  Create a tenant for the given Entity.

  ## Expected arguments

  * A `%Cashtrail.Entities.Entity{}` struct of the tenant that will be created.

  ## Returns

  * `{:ok, entity}` - If the tenant creation was successful performed.
  * `{:error, reason}` - In case of errors.

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

  ## Expected arguments

  * A `%Cashtrail.Entities.Entity{}` struct of the tenant that will be dropped.

  ## Returns

  * `{:ok, entity}` - If the tenant creation was successful performed.
  * `{:error, reason}` - In case of errors.

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

  ## Expected arguments

  * A `%Cashtrail.Entities.Entity{}` struct of the tenant that want to get the prefix.

  See `Triplex.to_prefix/1` docs for more information.
  """
  @spec to_prefix(Cashtrail.Entities.Entity.t()) :: String.t()
  def to_prefix(%Entity{} = entity) do
    Triplex.to_prefix(entity)
  end

  @doc """
  Return the given `Ecto.Queryable` with the prefix configured.

  ## Expected arguments

  * queryable - The `Ecto.Queryable` that the the prefix will be configured.
  * A `%Cashtrail.Entities.Entity{}` struct of the tenant that want to configure the prefix.

  See `Triplex.to_prefix/1` docs for more information.
  """
  @spec put_prefix(Ecto.Queryable.t(), Cashtrail.Entities.Entity.t()) :: Ecto.Query.t()
  def put_prefix(queryable, %Entity{} = entity) do
    queryable
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
  end
end
