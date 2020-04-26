defmodule Cashtray.Factory.Helpers do
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
end
