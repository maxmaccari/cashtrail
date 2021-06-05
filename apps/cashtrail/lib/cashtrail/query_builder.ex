defmodule Cashtrail.QueryBuilder do
  @moduledoc """
  This module is responsible to generate queries for contexts to filter and
  search by schema fields.
  """

  import Ecto.Query

  @doc """
  Returns a `Ecto.Query` with the queries based on the given filters and
  allowed fields, or the given `Ecto.Queryable` without changes.

  The query will use only the params that have the key in the allowed_filters param.

  ## Expected arguments

  * query - The `Ecto.Queryable` that the query will be performed.
  * params - A `map` keys of the fields and values to be filtered. The keys
  can be even `string` or `atom`, and the values must be the same type of
  the data in database, or can receive a list with data in the same type of the
  data in the database.
  * allowed_fields - A `list` of `atom` with the fields that will be used to perform
  the query. The query will be based only in params that have the keys matching
  this param.

  ## Examples

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Users.User, nil, [])
    Cashtrail.Users.User

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Users.User, %{first_name: "my name"}, [:first_name])
    #Ecto.Query<from u0 in Cashtrail.Users.User, where: u0.first_name == ^"my name">

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Users.User, %{first_name: ["my", "name"]}, [:first_name])
    #Ecto.Query<from u0 in Cashtrail.Users.User, where: u0.first_name in ^["my", "name"]>

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Users.User, %{"first_name" => "my name"}, [:first_name])
    #Ecto.Query<from u0 in Cashtrail.Users.User, where: u0.first_name == ^"my name">

    iex> Cashtrail.QueryBuilder.build_filter(Cashtrail.Users.User, %{"first_name" => ["my", "name"]}, [:first_name])
    #Ecto.Query<from u0 in Cashtrail.Users.User, where: u0.first_name in ^["my", "name"]>
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
  Returns a `Ecto.Query` with the queries based on the given term and fields,
  or the given `Ecto.Queryable` without changes.

  The search is implement using `ILIKE` in the fields of the given queryable
  schema. And the term must be a `string`.

  ## Expected arguments

  * query - The `Ecto.Queryable` that the query will be performed.
  * term - A `string` with the text that will be searched.
  * fields - A `list` of `atom` with the fields that will be used to perform
  the query. The given fields must be string or text, otherwise you will get
  an error from Ecto.

  ## Examples

    iex> Cashtrail.QueryBuilder.build_search(Cashtrail.Users.User, nil, [])
    Cashtrail.Users.User

    iex> Cashtrail.QueryBuilder.build_search(Cashtrail.Users.User, "my name", [:first_name, :last_name])
    #Ecto.Query<from u0 in Cashtrail.Users.User, or_where: ilike(u0.first_name, ^"%my name%"), or_where: ilike(u0.last_name, ^"%my name%")>
  """
  @spec build_search(Ecto.Queryable.t(), nil | String.t(), list(atom) | keyword()) ::
          Ecto.Query.t() | Ecto.Queryable.t()
  def build_search(query, nil, _), do: query

  def build_search(query, term, fields) do
    do_build_search(query, "%#{term}%", fields)
  end

  defp do_build_search(query, _, []), do: query

  defp do_build_search(query, term, [{relation, fields} | tail]) do
    query =
      join(query, :inner, [q], r in assoc(q, ^relation))
      |> build_relation_search(term, fields)

    do_build_search(query, term, tail)
  end

  defp do_build_search(query, term, [field | tail]) do
    query = from(q in query, or_where: ilike(field(q, ^field), ^term))

    do_build_search(query, term, tail)
  end

  defp build_relation_search(query, _term, []), do: query

  defp build_relation_search(query, term, [field | tail]) do
    query = or_where(query, [_q, r], ilike(field(r, ^field), ^term))

    build_relation_search(query, term, tail)
  end
end
