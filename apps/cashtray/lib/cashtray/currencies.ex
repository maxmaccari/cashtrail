defmodule Cashtray.Currencies do
  @moduledoc """
  The Currencies context manage the currencies data that are linked to Banking
  Accounts.
  """

  @type currency :: Cashtray.Currencies.Currency.t()

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Currencies.Currency
  alias Cashtray.Entities.Entity
  alias Cashtray.Paginator

  import Cashtray.Entities.Tenants, only: [to_prefix: 1]

  @doc """
  Returns the list of currencies paginated.

  You must pass the entity to find the currency correctely.

  Options:
    * `:filter` => filters by following attributes:
      * `:type` or `"type"`
      * `:active` or `"active"`
    * `:search` => search accounts by `:first_name`, `:last_name` and `:email`
    * See `Cashtray.Paginator.paginate/2` to see paginations options

  ## Examples

      iex> list_currencies(entity)
      %Cashtray.Paginator.Page{entries: [%Currency{}, ...], ...}

      iex> list_currencies(entity, page: 2)
      %Cashtray.Paginator.Page{entries: [%Currency{}, ...], page: 2}

      iex> list_currencies(entity, filter: %{type: "cash"})
      %Cashtray.Paginator.Page{entries: [%Currency{type: "cash"}, ...]}

      iex> list_currencies(entity, filter: %{search: "my"})
      %Cashtray.Paginator.Page{entries: [%Currency{description: "my cash"}, ...]}

  """
  @spec list_currencies(Entity.t(), keyword) :: Paginator.Page.t()
  def list_currencies(%Entity{} = entity, options \\ []) do
    Currency
    |> filter(Keyword.get(options, :filter))
    |> search(Keyword.get(options, :search))
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
    |> Paginator.paginate(options)
  end

  defp filter(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn
      {"type", value}, query -> from(q in query, where: [type: ^value])
      {:type, value}, query -> from(q in query, where: [type: ^value])
      {"active", value}, query -> from(q in query, where: [active: ^value])
      {:active, value}, query -> from(q in query, where: [active: ^value])
      _, query -> query
    end)
  end

  defp filter(query, _), do: query

  defp search(query, term) when is_binary(term) do
    term = "%#{term}%"

    from(q in query,
      where: ilike(q.description, ^term) or ilike(q.iso_code, ^term) or ilike(q.symbol, ^term)
    )
  end

  defp search(query, _), do: query

  @doc """
  Gets a single currency.

  You must pass the entity to find the currency correctely.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  ## Examples

      iex> get_currency!(entity, 123)
      %Currency{}

      iex> get_currency!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_currency!(Entity.t(), integer) :: currency
  def get_currency!(%Entity{} = entity, id) do
    Repo.get!(Currency, id, prefix: to_prefix(entity))
  end

  @doc """
  Creates a currency.

  You must pass the entity to create the currency correctely.

  ## Examples

      iex> create_currency(entity, %{field: value})
      {:ok, %Currency{}}

      iex> create_currency(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_currency(Entity.t(), map) ::
          {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def create_currency(%Entity{} = entity, attrs \\ %{}) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a currency.

  ## Examples

      iex> update_currency(currency, %{field: new_value})
      {:ok, %Currency{}}

      iex> update_currency(currency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_currency(currency, map) :: {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def update_currency(%Currency{} = currency, attrs) do
    currency
    |> Currency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a currency.

  ## Examples

      iex> delete_currency(currency)
      {:ok, %Currency{}}

      iex> delete_currency(currency)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_currency(currency) :: {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking currency changes.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{source: %Currency{}}

  """
  @spec change_currency(currency) :: Ecto.Changeset.t(currency)
  def change_currency(%Currency{} = currency) do
    Currency.changeset(currency, %{})
  end
end
