defmodule Cashtrail.Banking.Account do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a banking account of the entity.

  ## Definition

  According to [Investopedia](https://www.investopedia.com/terms/a/account.asp),
  the term account generally refers to a record-keeping or ledger activity. This
  can be any system of money in common use by people.

  You should first create an account to track the money or asset. One account could be your
  wallet, your saving account, checking account, or your brookerage account for example. Then you
  can create transactions to movement the account money or assets. And each account should have one
  currency linked.

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
  * `:status` - The status of the account, that can be:
    * `:active` - if the account is used and movimented.
    * `:archived` -if the account is no longer used and cannot be movimented, but want to keep
    the data history.
  * `:initial_balance_amount` - The initial balance of the account.
  * `:initial_balance_date` - The date of the initial balance of account. This cannot be changed
  after creation.
  * `:avatar_url` - One icon or image that represents this account.
  * `:restricted_transaction_types` - The transaction types that can be movimented by this account.
  If the list is empty this allow all transactions. Cannot be changed after creation.
  * `:identifier` - The data that identifies the account. See `Cashtrail.Banking.AccountIdentifier`
  to have more information.
  * `:currency` - The currency of the account. See `Cashtrail.Banking.Currency` to have more
  information. This cannot be  changed after account creation.
  * `:institution` - The institution of the account. See `Cashtrail.Banking.Institution` to have
  more inforation.
  * `:predicted_account` - If this account is a credit card or a loan, the predicted_account is
  where the transaction will be created.
  * `:inserted_at` - When the account was inserted at the first time.
  * `:updated_at` - When the account was updated at the last time.

  See `Cashtrail.Banking` to know how to list, get, insert, update, and delete accounts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Banking

  @type account_type :: :cash | :checking | :saving | :digital | :credit | :investment | :other
  @type transaction_type :: :income | :expense | :tax | :transfer | :exchange | :refund
  @type status :: :active | :archived
  @type t :: %Cashtrail.Banking.Account{
          id: Ecto.UUID.t() | nil,
          description: String.t() | nil,
          type: account_type() | nil,
          status: status() | nil,
          initial_balance_amount: Decimal.t() | nil,
          initial_balance_date: Date.t() | nil,
          avatar_url: String.t() | nil,
          restricted_transaction_types: list(transaction_type) | nil,
          identifier: Banking.AccountIdentifier.t() | nil,
          currency: Banking.Currency.t() | nil,
          institution: Banking.Institution.t() | nil,
          predicted_account: Banking.Account.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :description, :string

    field :type, Ecto.Enum,
      values: [:cash, :checking, :saving, :digital, :credit, :investment, :other],
      default: :cash

    field :status, Ecto.Enum, values: [:active, :archived], default: :active
    field :initial_balance_amount, :decimal, default: 0
    field :initial_balance_date, :date
    field :avatar_url, :string

    field :restricted_transaction_types, {:array, Ecto.Enum},
      values: [:income, :expense, :tax, :transfer, :exchange, :refund],
      default: []

    embeds_one :identifier, Banking.AccountIdentifier, on_replace: :update

    belongs_to :currency, Banking.Currency
    belongs_to :institution, Banking.Institution
    belongs_to :predicted_account, Banking.Account

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :description,
      :type,
      :initial_balance_amount,
      :initial_balance_date,
      :restricted_transaction_types,
      :avatar_url,
      :currency_id,
      :institution_id,
      :predicted_account_id
    ])
    |> validate_required([:description, :currency_id])
    |> cast_embed(:identifier)
    |> foreign_key_constraint(:currency_id)
    |> foreign_key_constraint(:institution_id)
    |> foreign_key_constraint(:predicted_account_id)
  end

  @doc false
  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [
      :description,
      :initial_balance_amount,
      :avatar_url,
      :institution_id,
      :predicted_account_id,
      :status
    ])
    |> validate_required([:description, :currency_id])
    |> cast_embed(:identifier)
    |> foreign_key_constraint(:institution_id)
    |> foreign_key_constraint(:predicted_account_id)
  end
end
