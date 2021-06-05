defmodule Cashtrail.Banking.Account do
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
