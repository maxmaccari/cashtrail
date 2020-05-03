defmodule Cashtrail.Banking.Currencies do
  @moduledoc """
  The Currencies context manages the currencies data of one entity.

  See `Cashtrail.Banking.Currencies.Currency` to have more info about what
  currencies mean in the application.
  """

  import Ecto.Query, warn: false
  alias Cashtrail.Repo

  alias Cashtrail.Banking.Currencies.Currency
  alias Cashtrail.Entities.Entity
  alias Cashtrail.Paginator

  import Cashtrail.Entities.Tenants, only: [to_prefix: 1]
  import Cashtrail.QueryBuilder, only: [build_filter: 3, build_search: 3]

  @type currency :: Currency.t()

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of currencies in the
  `:entries` field.

  If no currencies are found, returns an empty list in the `:entries` field.

  ## Expected arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the currency references.
  * options - A `keyword` list of the following options:
    * `:filter` - filters by following attributes:
      * `:type` or `"type"`
      * `:active` or `"active"`
    * `:search` - search currencies by `:description`, `:iso_code` and `:symbol`.
    * See `Cashtrail.Paginator.paginate/2` to know about the paginations options.

  See `Cashtrail.Banking.Currencies.Currency` to have more detailed info about
  each field to be filtered or searched.

  ## Examples

      iex> list_currencies(entity)
      %Cashtrail.Paginator.Page{entries: [%Currency{}, ...], ...}

      iex> list_currencies(entity, page: 2)
      %Cashtrail.Paginator.Page{entries: [%Currency{}, ...], page: 2}

      iex> list_currencies(entity, filter: %{type: "money"})
      %Cashtrail.Paginator.Page{entries: [%Currency{type: "money"}, ...]}

      iex> list_currencies(entity, filter: %{search: "my"})
      %Cashtrail.Paginator.Page{entries: [%Currency{description: "my money"}, ...]}
  """
  @spec list_currencies(Entity.t(), keyword) :: Paginator.Page.t()
  def list_currencies(%Entity{} = entity, options \\ []) do
    Currency
    |> build_filter(Keyword.get(options, :filter), [:type, :active])
    |> build_search(Keyword.get(options, :search), [:description, :iso_code, :symbol])
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single currency.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  See `Cashtrail.Banking.Currencies.Currency` to have more detailed info about
  the returned struct.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the currency references.

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

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the currency references.
  * params - A `map` with the params of the currency to be created:
    * `:description` (required) - A `string` that is the description of the currency.
    * `:type` - A `string` that is the type of the currency. It can receive "money",
    "digital_currency", "miles", "cryptocurrency" or "other". Defaults to
    "money".
    * `:iso_code` - A `string` that is the [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217)
    code of the currency. Must be unique for the entity and have the exact 3 characters.
    * `:symbol` - A `string` that is the symbol of the currency.
    * `:format` - A `string` that represents the format of the currency. The "%s"
    refers to the `:symbol` field, and the "%n" refers to the number. Defaults to "%s%n".
    * `:precision` - A `integer` that represents how much decimal places the currency
    have. Defaults to 0.
    * `:separator` - A `string` that is used to separate the integer part from the
    fractional part of the currency. It must have exact one character or be empty.
    Defaults to ".".
    * `:delimiter` - A `string` that is used to separate the thousands parts of
    the currency. Defaults to ".".
    * `:active` - A `boolean` that says if the currency is active and should be
    displayed in lists of the application. Defaults to true.

  See `Cashtrail.Banking.Currencies.Currency` to have more detailed info about
  the fields.

  ## Returns

  * `{:ok, %Cashtrail.Banking.Currencies.Currency{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> create_currency(entity, %{field: value})
      {:ok, %Currency{}}

      iex> create_currency(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_currency(Entity.t(), map) ::
          {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def create_currency(%Entity{} = entity, attrs) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a currency.

  ## Expected Arguments

  * currency - The `%Cashtrail.Banking.Currencies.Currency{}` to be updated.
  * params - A `map` with the field of the currency to be updated. See
  `create_currency/2` to know about the params that can be given.

  ## Returns

  * `{:ok, %Cashtrail.Banking.Currencies.Currency{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

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

  ## Expected Arguments

  * currency - The `%Cashtrail.Banking.Currencies.Currency{}` to be deleted.

  ## Returns

  * `{:ok, %Cashtrail.Banking.Currencies.Currency{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

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


  ## Expected Arguments

  * currency - The `%Cashtrail.Banking.Currencies.Currency{}` to be tracked.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{source: %Currency{}}

  """
  @spec change_currency(currency) :: Ecto.Changeset.t(currency)
  def change_currency(%Currency{} = currency) do
    Currency.changeset(currency, %{})
  end
end
