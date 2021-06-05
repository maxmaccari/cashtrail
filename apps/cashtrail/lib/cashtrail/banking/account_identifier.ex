defmodule Cashtrail.Banking.AccountIdentifier do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtrail.Banking.AccountIdentifier{
          id: Ecto.UUID.t() | nil,
          bank_code: String.t() | nil,
          branch: String.t() | nil,
          number: String.t() | nil,
          swift: String.t() | nil,
          iban: String.t() | nil
        }

  embedded_schema do
    field :bank_code, :string
    field :branch, :string
    field :number, :string
    field :swift, :string
    field :iban, :string
  end

  @doc false
  def changeset(account_identifier, attrs) do
    account_identifier
    |> cast(attrs, [:bank_code, :branch, :number, :swift, :iban])
  end
end
