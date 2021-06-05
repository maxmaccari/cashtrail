defmodule Cashtrail.Banking.AccountIdentifier do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents the data the identifies one bank account.

  ## Fields

  * `:id` - The unique id of the account identifier.
  * `:bank_code` - the bank code assigned by a central bank.
  * `:branch` - the branch number of the bank.
  * `:number` - the number of the individual bank account.
  * `:swift` - the international [swift](https://www.investopedia.com/articles/personal-finance/050515/how-swift-system-works.asp) code of the bank.
  * `:iban` - the internation (iban)[https://www.investopedia.com/terms/i/iban.asp] number of the account.
  """

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

  @swift_regex ~r/[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?/i
  @iban_regex ~r/^([A-Z]{2}[ \-]?[0-9]{2})(?=(?:[ \-]?[A-Z0-9]){9,30}$)((?:[ \-]?[A-Z0-9]{3,5}){2,7})([ \-]?[A-Z0-9]{1,3})?$/i
  @doc false
  def changeset(account_identifier, attrs) do
    account_identifier
    |> cast(attrs, [:bank_code, :branch, :number, :swift, :iban])
    |> validate_format(:swift, @swift_regex, message: "is not a valid swift")
    |> validate_format(:iban, @iban_regex, message: "is not a valid iban")
  end
end
