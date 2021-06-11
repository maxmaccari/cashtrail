defmodule Cashtrail.Statuses do
  @moduledoc """
  Provides a set of functions to work with status on Ecto Schemas records that implements
  `WithStatus` protocol.

  If the record has one field called `:archived_at` and want map this field to `:active` or
  `:archived` state. It is only necessary to set `@derive Cashtrail.Statuses.WithStatus` on the
  Ecto.Schema model. For example:

  ```
  defmodule MySchema do
    use Ecto.Schema

    @derive Cashtrail.Statuses.WithStatus

    schema "my_table" do
      field :description, :string
      field :archived_at, :naive_datetime
    end
  end
  ```

  In other cases is necessary implement the protocol functions from `Cashtrail.Statuses.WithStatus`,
  like for example:

  ```
  defimpl WithStatus, for: Any do
    import Ecto.Query

    @spec status(struct) :: :archived | :active
    def status(%{archived_at: archived_at}) when not is_nil(archived_at) do
      :archived
    end

    def status(_) do
      :active
    end

    @spec filter_condition(struct, atom) :: Ecto.Query.Dynamic.t() | nil
    def filter_condition(_schema, :active) do
      dynamic([q], is_nil(q.archived_at))
    end

    def filter_condition(_schema, :archived) do
      dynamic([q], not is_nil(q.archived_at))
    end

    def filter_condition(_schema, _status), do: nil
  end
  ```
  """

  alias Cashtrail.Statuses.WithStatus
  import Ecto.Query

  @doc """
  Gets the status of one record.
  """
  @spec status(struct) :: atom
  def status(record) do
    WithStatus.status(record)
  end

  @doc """
  Returns if the record is archived or don't based on it status.
  """
  @spec archived?(struct) :: boolean
  def archived?(record) do
    case status(record) do
      :archived -> true
      _ -> false
    end
  end

  @doc """
  Returns if the record is active or don't based on it status. It is considered active if it is not
  archived.
  """
  @spec active?(struct) :: boolean
  def active?(record) do
    case status(record) do
      :archived -> false
      _ -> true
    end
  end

  @doc """
  Returns a `Ecto.Query` with the queries based on the given status.

  The query is mounted according with the implementation of the `WithStatus.filter_condition/2`
  function.

  ## Arguments
  * query
  """
  @spec filter_by_status(Ecto.Queryable.t() | Ecto.Query.t(), map(), atom()) :: Ecto.Query.t()
  def filter_by_status(queryable, params, status_key \\ :status)

  def filter_by_status(queryable, nil, _status_key), do: queryable

  def filter_by_status(queryable, params, status_key) do
    status_or_statuses =
      case Map.get(params, status_key) || Map.get(params, to_string(status_key)) do
        [status | _] = statuses when is_binary(status) ->
          Enum.map(statuses, &String.to_existing_atom/1)

        status when is_binary(status) ->
          String.to_existing_atom(status)

        status_or_statuses ->
          status_or_statuses
      end

    build_filter(queryable, status_or_statuses)
  end

  @spec build_filter(Ecto.Queryable.t() | Ecto.Query.t(), atom() | list(atom())) :: Ecto.Query.t()
  defp build_filter(%Ecto.Query{from: %{source: {_, schema}}} = query, status_or_statuses) do
    schema = Cashtrail.Repo.load(schema, %{})

    build_filter(query, status_or_statuses, schema)
  end

  defp build_filter(query, status_or_statuses) do
    schema = Cashtrail.Repo.load(query, %{})

    build_filter(query, status_or_statuses, schema)
  end

  @spec build_filter(Ecto.Queryable.t(), atom() | list(atom()), Ecto.Schema.t()) :: Ecto.Query.t()
  defp build_filter(query, statuses, schema) when is_list(statuses) do
    conditions =
      Enum.reduce(statuses, false, fn status, condition ->
        case WithStatus.filter_condition(schema, status) do
          nil -> condition
          filter_condition -> dynamic([q], ^filter_condition or ^condition)
        end
      end)

    from(query, where: ^conditions)
  end

  defp build_filter(query, status, schema) do
    conditions = WithStatus.filter_condition(schema, status) || []

    from(query, where: ^conditions)
  end

  defprotocol WithStatus do
    @moduledoc """
    Gets the status from the record and helps build filters for the record and the status.
    """

    @doc """
    Gets the status of the record.
    """
    @spec status(struct()) :: atom()
    def status(record)

    @doc """
    Build the filter condition for the record and the given status.
    """
    @spec filter_condition(struct(), atom()) :: Ecto.Query.Dynamic.t() | nil
    def filter_condition(record, status)
  end

  defimpl WithStatus, for: Any do
    @moduledoc false

    import Ecto.Query

    @doc false
    @spec status(struct) :: :archived | :active
    def status(%{archived_at: archived_at}) when not is_nil(archived_at) do
      :archived
    end

    def status(_) do
      :active
    end

    @doc false
    @spec filter_condition(struct, atom) :: Ecto.Query.Dynamic.t() | nil
    def filter_condition(_schema, :active) do
      dynamic([q], is_nil(q.archived_at))
    end

    def filter_condition(_schema, :archived) do
      dynamic([q], not is_nil(q.archived_at))
    end

    def filter_condition(_schema, _status), do: nil
  end
end
