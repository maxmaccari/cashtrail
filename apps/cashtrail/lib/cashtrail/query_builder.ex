defmodule Cashtrail.QueryBuilder do
  @moduledoc """
  This module is responsible to generate queries for contexts to filter and
  search by schema fields.
  """

  import Ecto.Query

  @doc """
  Builds a query to fiter the queryable by the given params. The params
  are a map. The keys can be even `string` or `atom`, and the values must be
  the same type of the related schema field, and it can be a list of values too.

  The params used in the filter will be only the one that are put in the
  allowed_filters params.

  ## Examples

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Accounts.User, nil, [])
    Cashtrail.Accounts.User

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Accounts.User, %{first_name: "my name"}, [:first_name])
    #Ecto.Query<from u0 in Cashtrail.Accounts.User, where: u0.first_name == ^"my name">

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Accounts.User, %{first_name: ["my", "name"]}, [:first_name])
    #Ecto.Query<from u0 in Cashtrail.Accounts.User, where: u0.first_name in ^["my", "name"]>
  """
  @spec build_filter(Ecto.Queryable.t(), nil | map, list(atom)) ::
          Ecto.Query.t() | Ecto.Queryable.t()
  def build_filter(query, nil, _), do: query

  def build_filter(query, params, allowed_filters) do
    params
    |> Enum.map(&convert_key_to_atom/1)
    |> Enum.filter(&filter_allowed(&1, allowed_filters))
    |> Enum.reduce(query, fn
      {key, value}, query when is_list(value) ->
        from(q in query, where: field(q, ^key) in ^value)

      {key, value}, query ->
        from(q in query, where: field(q, ^key) == ^value)
    end)
  end

  defp convert_key_to_atom({key, value}) when is_binary(key),
    do: {String.to_existing_atom(key), value}

  defp convert_key_to_atom(term), do: term

  defp filter_allowed({key, _}, allowed_filters), do: key in allowed_filters

  @doc """
  Builds a query to search the queryable by the given term in the given fields.

  The search is implement using `ILIKE` in the fields of the given queryable
  schema. And the term must be a `string`.

  ## Examples

    iex> Cashtrail.QueryBuilder.build_search(Cashtrail.Accounts.User, nil, [])
    Cashtrail.Accounts.User

    iex> Cashtrail.QueryBuilder.build_search(Cashtrail.Accounts.User, "my name", [:first_name, :last_name])
    #Ecto.Query<from u0 in Cashtrail.Accounts.User, or_where: ilike(u0.first_name, ^"%my name%"), or_where: ilike(u0.last_name, ^"%my name%")>
  """
  @spec build_search(Ecto.Queryable.t(), nil | String.t(), list(atom)) ::
          Ecto.Query.t() | Ecto.Queryable.t()
  def build_search(query, nil, _), do: query

  def build_search(query, term, fields) do
    do_build_search(query, "%#{term}%", fields)
  end

  defp do_build_search(query, _, []), do: query

  defp do_build_search(query, term, [field | tail]) do
    query = from(q in query, or_where: ilike(field(q, ^field), ^term))

    do_build_search(query, term, tail)
  end
end
