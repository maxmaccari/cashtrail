defmodule Cashtrail.Factory.Helpers do
  @moduledoc false

  def forget(_, _, cardinality \\ :one)

  def forget(struct, fields, cardinality) when is_list(fields),
    do:
      fields
      |> Enum.reduce(struct, fn field, acc ->
        forget(acc, field, cardinality)
      end)

  def forget(struct, field, cardinality) do
    %{
      struct
      | field => %Ecto.Association.NotLoaded{
          __field__: field,
          __owner__: struct.__struct__,
          __cardinality__: cardinality
        }
    }
  end

  def put_tenant(struct, %{tenant: tenant}) do
    Ecto.put_meta(struct, prefix: Cashtrail.Entities.Tenants.to_prefix(tenant))
  end

  def put_tenant(struct, _), do: struct

  def drop_tenant(%{tenant: _} = attrs) do
    Map.drop(attrs, [:tenant])
  end

  def drop_tenant(attrs), do: attrs
end
