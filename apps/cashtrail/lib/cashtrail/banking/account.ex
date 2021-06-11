defmodule Cashtrail.Banking.Account do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a banking account of the entity.

  ## Definition

  According to [Investopedia](https://www.investopedia.com/terms/a/account.asp),
  the term account generally refers to a record-keeping or ledger activity. This
  can be any system of money in common use by people.

  You should first create an account to track the money or asset. One account could be your
  wallet, your saving account, checking account, or your brookerage account for example. Then you
  can create transactions to movement the account money or assets.

  ## Fields

  * `:id` - The unique id of the account.
  * `:description` - The description of the account.
  * `:type` - The type of account. Can be:
    * `:cash` - To be used to track phisical money, like wallets or cashier.
    * `:checking` - To be used to track savings accounts.
    * `:saving` - To be used to track checking accounts.
    * `:digital` - To be used to track digital accounts.
    * `:credit` - To be used to track loans, financings, or credit cards.
    * `:investment` - To be used to track investments, like broker account.
    * `:other` - To be used to track other kind of account that was not listed.
  * `:initial_balance_amount` - The initial balance of the account.
  * `:initial_balance_date` - The date of the initial balance of account. This cannot be changed
  after creation.
  * `:avatar_url` - One icon or image that represents this account.
  * `:restricted_transaction_types` - The transaction types that can be movimented by this account.
  If the list is empty this allow all transactions. Cannot be changed after creation.
  * `:identifier` - The data that identifies the account. See `Cashtrail.Banking.AccountIdentifier`
  to have more information.
  * `:currency` - The iso code of the currency used by the account. This cannot be  changed after
  account creation.
  * `:institution` - The institution of the account. See `Cashtrail.Banking.Institution` to have
  more inforation.
  * `:predicted_account` - If this account is a credit card or a loan, the predicted_account is
  where the transaction will be created.
  * `:archived_at` - When the account was archived.
  * `:inserted_at` - When the account was inserted at the first time.
  * `:updated_at` - When the account was updated at the last time.

  See `Cashtrail.Banking` to know how to list, get, insert, update, and delete accounts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Banking

  @derive Cashtrail.Statuses.WithStatus

  @type account_type :: :cash | :checking | :saving | :digital | :credit | :investment | :other
  @type transaction_type :: :income | :expense | :tax | :transfer | :exchange | :refund
  @type t :: %Cashtrail.Banking.Account{
          id: Ecto.UUID.t() | nil,
          description: String.t() | nil,
          type: account_type() | nil,
          initial_balance_amount: number() | Decimal.t() | nil,
          initial_balance_date: Date.t() | nil,
          avatar_url: String.t() | nil,
          restricted_transaction_types: list() | nil,
          identifier: Banking.AccountIdentifier.t() | nil,
          currency: String.t() | nil,
          institution: Banking.Institution.t() | Ecto.Association.NotLoaded.t() | nil,
          institution_id: Ecto.UUID.t() | nil,
          predicted_account: Banking.Account.t() | Ecto.Association.NotLoaded.t() | nil,
          predicted_account_id: Ecto.UUID.t() | nil,
          archived_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :description, :string
    field :currency, :string

    field :type, Ecto.Enum,
      values: [:cash, :checking, :saving, :digital, :credit, :investment, :other],
      default: :cash

    field :initial_balance_amount, :decimal, default: 0
    field :initial_balance_date, :date
    field :avatar_url, :string

    field :restricted_transaction_types, {:array, Ecto.Enum},
      values: [:income, :expense, :tax, :transfer, :exchange, :refund],
      default: []

    embeds_one :identifier, Banking.AccountIdentifier, on_replace: :update

    belongs_to :institution, Banking.Institution
    belongs_to :predicted_account, Banking.Account

    field :archived_at, :naive_datetime
    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :description,
      :currency,
      :type,
      :initial_balance_amount,
      :initial_balance_date,
      :restricted_transaction_types,
      :avatar_url,
      :institution_id,
      :predicted_account_id
    ])
    |> validate_required([:description])
    |> cast_embed(:identifier)
    |> foreign_key_constraint(:institution_id)
    |> foreign_key_constraint(:predicted_account_id)
  end

  @doc false
  @spec update_changeset(t | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [
      :description,
      :initial_balance_amount,
      :avatar_url,
      :institution_id,
      :predicted_account_id
    ])
    |> validate_required([:description])
    |> cast_embed(:identifier)
    |> foreign_key_constraint(:institution_id)
    |> foreign_key_constraint(:predicted_account_id)
  end

  @spec archive_changeset(t | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def archive_changeset(account) do
    change(account, %{archived_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)})
  end

  @spec unarchive_changeset(t | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def unarchive_changeset(account) do
    change(account, %{archived_at: nil})
  end
end
