defmodule Cashtrail.Banking do
  @moduledoc """
  The Banking context manages registers for bank accounts and currencies
  for its accounts.

  See `Cashtrail.Banking.Currency` to have more info about what currencies mean
  in the application, and `Cashtrail.Banking.Accounts` to have more info about
  what accounts mean in the application.
  """

  import Ecto.Query, warn: false
  alias Cashtrail.Repo

  alias Cashtrail.{Banking, Entities, Paginator}

  import Cashtrail.Entities.Tenants, only: [to_prefix: 1]
  import Cashtrail.QueryBuilder, only: [build_filter: 3, build_search: 3]

  @type currency :: Banking.Currency.t()
  @type institution :: Banking.Institution.t()

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of currencies in the
  `:entries` field.

  If no currencies are found, return an empty list in the `:entries` field.

  ## Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the currency references.
  * options - A `keyword` list of the following options:
    * `:filter` - filters by following attributes:
      * `:type` or `"type"`
      * `:status` or `"status"`
    * `:search` - search currencies by `:description`, `:iso_code` and `:symbol`.
    * See `Cashtrail.Paginator.paginate/2` to know about the pagination options.

  See `Cashtrail.Banking.Currency` to have more detailed info about
  each field to be filtered or searched.

  ## Examples

      iex> list_currencies(entity)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Currency{}, ...], ...}

      iex> list_currencies(entity, page: 2)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Currency{}, ...], page: 2}

      iex> list_currencies(entity, filter: %{type: "money"})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Currency{type: :money}, ...]}

      iex> list_currencies(entity, filter: %{search: "my"})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Currency{description: "my money"}, ...]}
  """
  @spec list_currencies(Entities.Entity.t(), keyword) :: Paginator.Page.t()
  def list_currencies(%Entities.Entity{} = entity, options \\ []) do
    Banking.Currency
    |> build_filter(Keyword.get(options, :filter), [:type, :status])
    |> build_search(Keyword.get(options, :search), [:description, :iso_code, :symbol])
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single currency.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  See `Cashtrail.Banking.Currency` to have more detailed info about the struct returned.

  ## Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the currency references.
  * id - A `string` that is the unique id of the currency to be found.

  ## Examples

      iex> get_currency!(entity, 123)
      %Cashtrail.Banking.Currency{}

      iex> get_currency!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_currency!(Entities.Entity.t(), Ecto.UUID.t() | String.t()) :: currency
  def get_currency!(%Entities.Entity{} = entity, id) do
    Repo.get!(Banking.Currency, id, prefix: to_prefix(entity))
  end

  @doc """
  Creates a currency.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the currency references.
  * params - A `map` with the params of the currency to be created:
    * `:description` (required) - A `string` that is the description of the currency.
    * `:type` - A `string` or `atom` that is the type of currency. It can receive `:money`,
    `:digital_currency`, `:virtual`, `:cryptocurrency` or `:other`. Defaults to
    `:money`.
    * `:iso_code` - A `string` that is the [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217)
    code of the currency. Must be unique for the entity and have the exact 3 characters.
    * `:symbol` - A `string` that is the symbol of the currency.
    * `:format` - A `string` that represents the format of the currency. The "%s"
    refers to the `:symbol` field, and the "%n" refers to the number. Defaults to "%s%n".
    * `:precision` - A `integer` that represents how much decimal places the currency
    has. Defaults to 0.
    * `:separator` - A `string` that is used to separate the integer part from the
    fractional part of the currency. It must have an exact one character or be empty.
    Defaults to ".".
    * `:delimiter` - A `string` that is used to separate the thousands parts of
    the currency. Defaults to ".".
    * `:status` - A `string` or `atom` value that says if the currency is status and should be
    displayed in lists of the application. Can be `:active` or `:archived`. Defaults to `:active`.

  See `Cashtrail.Banking.Currency` to have more detailed info about
  the fields.

  ## Examples

      iex> create_currency(entity, %{field: value})
      {:ok, %Cashtrail.Banking.Currency{}}

      iex> create_currency(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_currency(Entities.Entity.t(), map) ::
          {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def create_currency(%Entities.Entity{} = entity, attrs) do
    %Banking.Currency{}
    |> Banking.Currency.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a currency.

  ## Arguments

  * currency - The `%Cashtrail.Banking.Currency{}` to be updated.
  * params - A `map` with the field of the currency to be updated. See
  `create_currency/2` to know about the params that can be given.

  ## Examples

      iex> update_currency(currency, %{field: new_value})
      {:ok, %Cashtrail.Banking.Currency{}}

      iex> update_currency(currency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_currency(currency, map) :: {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def update_currency(%Banking.Currency{} = currency, attrs) do
    currency
    |> Banking.Currency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a currency.

  ## Expected Arguments

  * currency - The `%Cashtrail.Banking.Currency{}` to be deleted.

  ## Examples

      iex> delete_currency(currency)
      {:ok, %Cashtrail.Banking.Currency{}}

      iex> delete_currency(currency)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_currency(currency) :: {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def delete_currency(%Banking.Currency{} = currency) do
    Repo.delete(currency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking currency changes.

  ## Arguments

  * currency - The `%Cashtrail.Banking.Currency{}` to be tracked.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{source: %Cashtrail.Banking.Currency{}}

  """
  @spec change_currency(currency) :: Ecto.Changeset.t(currency)
  def change_currency(%Banking.Currency{} = currency) do
    Banking.Currency.changeset(currency, %{})
  end

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of institutions in the
  `:entries` field.

  If no institutions are found, return an empty list in the `:entries` field.

  ## Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the institution references.
  * options - A `keyword` list of the following options:
    * `:search` - search institutions by :country, or by the contact `:name`, or
    `:legal_name`.
    * See `Cashtrail.Paginator.paginate/2` to know about the pagination options.

  See `Cashtrail.Banking.Institution` to have more detailed info about
  each field to be filtered or searched.

  ## Examples

      iex> list_institutions(entity)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Institution{}, ...], ...}

      iex> list_institutions(entity, page: 2)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Institution{}, ...], page: 2}

      iex> list_institutions(entity, search: "My Bank")
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Institution{name: "My Bank"}, ...]}

      iex> list_institutions(entity, search: "My Legal Bank"})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Institution{legal_name: "My Legal Bank"}, ...]}
  """
  @spec list_institutions(Entities.Entity.t(), keyword()) :: Paginator.Page.t()
  def list_institutions(%Entities.Entity{} = entity, options \\ []) do
    Banking.Institution
    |> build_search(Keyword.get(options, :search), [:country, contact: [:name, :legal_name]])
    |> Ecto.Queryable.to_query()
    |> preload([], contact: :category)
    |> Map.put(:prefix, to_prefix(entity))
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single institution.

  Raises `Ecto.NoResultsError` if the Institution does not exist.

  See `Cashtrail.Banking.Institution` to have more detailed info about
  the returned struct.

  ## Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the institution references.
  * id - A `string` that is the unique id of the institution to be found.

  ## Examples

      iex> get_institution!(entity, 123)
      %Institution{}

      iex> get_institution!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_institution!(Entities.Entity.t(), Ecto.UUID.t()) :: institution()
  def get_institution!(%Entities.Entity{} = entity, id) do
    Repo.get!(Banking.Institution, id, prefix: to_prefix(entity))
    |> Repo.preload(contact: :category)
  end

  @doc """
  Creates a institution.

  ## Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the institution references.
  * params - A `map` with the params of the currency to be created:
    * `:contact` or :contact_id (required) -
      * `:contact_id` - `string` that is the description uuid of the contact.
      * `:contact` - a `map` with data about the contact to be created an referenced
      by the institution. See `Cashtrail.Contacts.Contact` or `Cashtrail.Contacts.create_contact/2`
      to have more information about accepted fields.
    * `:country` - A `string` with the country where the institution is located.
    * `:bank_code` - A `string` with the code of the institution in the country
    that the institution is located.
    * `:swift` - A `string` with the SWIFT code that identifies a particular
    bank worldwide.
    * `:logo_url` - A `string` with the url with the logo of the institution.

  See `Cashtrail.Banking.Institution` to have more detailed info about
  the fields.

  ## Examples

      iex> create_institution(%{field: value})
      {:ok, %Institution{}}

      iex> create_institution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_institution(Entities.Entity.t(), map()) ::
          {:ok, institution()} | {:error, Ecto.Changeset.t(institution())}
  def create_institution(%Entities.Entity{} = entity, attrs \\ %{}) do
    %Banking.Institution{}
    |> Banking.Institution.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
    |> load_contact()
  end

  defp load_contact(
         {:ok, %Banking.Institution{contact: %Ecto.Association.NotLoaded{}} = institution}
       ) do
    {:ok, Repo.preload(institution, :contact)}
  end

  defp load_contact(result), do: result

  @doc """
  Updates a institution.

  ## Arguments

  * institution - The `%Cashtrail.Banking.Institution{}` to be updated.
  * params - A `map` with the field of the institution to be updated. See
  `create_institution/2` to know about the params that can be given.

  ## Examples

      iex> update_institution(institution, %{field: new_value})
      {:ok, %Institution{}}

      iex> update_institution(institution, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_institution(institution(), map()) ::
          {:ok, institution()} | {:error, Ecto.Changeset.t(institution())}
  def update_institution(%Banking.Institution{} = institution, attrs) do
    institution
    |> Banking.Institution.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a institution.

  ## Arguments

  * institution - The `%Cashtrail.Banking.Institution{}` to be deleted.

  ## Examples

      iex> delete_institution(institution)
      {:ok, %Institution{}}

      iex> delete_institution(institution)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_institution(institution()) ::
          {:ok, institution()} | {:error, Ecto.Changeset.t(institution())}
  def delete_institution(%Banking.Institution{} = institution) do
    Repo.delete(institution)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking institution changes.

  ## Arguments

  * institution - The `%Cashtrail.Banking.Institution{}` to be tracked.

  ## Examples

      iex> change_institution(institution)
      %Ecto.Changeset{data: %Institution{}}

  """
  @spec change_institution(institution(), map()) ::
          Ecto.Changeset.t(institution())
  def change_institution(%Banking.Institution{} = institution, attrs \\ %{}) do
    Banking.Institution.changeset(institution, attrs)
  end

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of accounts in the `:entries` field.

  If no accounts are found, return an empty list in the `:entries` field.

  ## Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the account references.
  * options - A `keyword` list of the following options:
    * `:filter` - filters by following attributes:
      * `:type` or `"type"`
      * `:status` or `"status"`
      * `:currency_id` or `"currency_id"`
      * `:institution_id` or `"institution_id"`
    * `:search` - search accounts by `:description`.
    * See `Cashtrail.Paginator.paginate/2` to know about the pagination options.

  See `Cashtrail.Banking.Account` to have more detailed info about each field to be filtered or
  searched.

  ## Examples

       iex> list_accounts(entity)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Account{}, ...], ...}

      iex> list_accounts(entity, page: 2)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Account{}, ...], page: 2}

      iex> list_accounts(entity, filter: %{type: "cash"})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Account{type: :cash}, ...]}

      iex> list_accounts(entity, filter: %{search: "my"})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Banking.Account{description: "my cash"}, ...]}

  """
  def list_accounts(%Entities.Entity{} = entity, options \\ []) do
    Banking.Account
    |> build_filter(Keyword.get(options, :filter), [:type, :status, :currency_id, :institution_id])
    |> build_search(Keyword.get(options, :search), [:description])
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  See `Cashtrail.Banking.Account` to have more detailed info about the struct returned.

  ## Examples

      iex> get_account!(entity, 123)
      %Cashtrail.Banking.Account{}

      iex> get_account!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(%Entities.Entity{} = entity, id) do
    Repo.get!(Banking.Account, id, prefix: to_prefix(entity))
  end

  @doc """
  Creates a account.

  * entity - The `%Cashtrail.Entities.Entity{}` that the account references.
  * params - A `map` with the params of the account to be created:
    * `:description` (required)
    * `:type` - A `string` or `atom` that is the type of account. It can receive `:cash`,
    `:checking`, `:saving`, `:digital`, `:credit`, `:investment` or `:other`. Defaults to
    `:cash`.
    * `:type` - A `string` or `atom` that is the status of account. It can receive `:cash`,
    `:checking`, `:saving`, `:digital`, `:credit`, `:investment` or `:other`. Defaults to
    `:cash`.
    * `:initial_balance_amount` - A `number` with the initial balance value of the account.
    * `:initial_balance_date` - A `date` with the initial balance date of the account. This cannot
    be changed.
    * `:avatar_url` - A `string` with the avatar url of the account.
    * `:restricted_transaction_types` - A `list` of `string` or `atoms` with transaction types that
    are allowed. Can receive `:income`, `:expense`, `:tax`, `:transfer`, `:exchange` or `:refund`.
    * `:identifier` - A `map` with the data that identifies the account in real world. The fields
    are `:bank_code`, `:branch`, `:number`, `:swift` and `:iban`.
    * `:currency_id` - The id of the currency of the account. This cannot be changed.
    * `:institution_id` - The id of the institution of the account.
    * `:predicted_account_id` - The id of the account that will be predicted.

  See `Cashtrail.Banking.Account` to have more detailed info about the fields.

  ## Examples

      iex> create_account(entity, %{field: value})
      {:ok, %Cashtrail.Banking.Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(%Entities.Entity{} = entity, attrs \\ %{}) do
    %Banking.Account{}
    |> Banking.Account.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a account.

  * params - A `map` with the field of the account to be updated. See
  `create_account/2` to know about the params that can be given.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Banking.Account{} = account, attrs) do
    account
    |> Banking.Account.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Arguments

  * account - The `%Cashtrail.Banking.Account{}` to be deleted.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Banking.Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Arguments

  * account - The `%Cashtrail.Banking.Account{}` to be tracked.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Banking.Account{} = account, attrs \\ %{}) do
    case Ecto.get_meta(account, :state) do
      :built -> Banking.Account.changeset(account, attrs)
      _ -> Banking.Account.update_changeset(account, attrs)
    end
  end
end
