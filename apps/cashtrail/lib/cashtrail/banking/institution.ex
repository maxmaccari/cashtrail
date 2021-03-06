defmodule Cashtrail.Banking.Institution do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a financial institution of the entity.

  ## Definition
  According with [Investopedia](https://www.investopedia.com/terms/f/financialinstitution.asp),
  the financial institution is a company engaged in the business of dealing with financial
  and monetary transactions such as deposits, loans, investments, and currency exchange.
  financial institutionS can be banks, brokers, investiments dealers, or currency exchange.

  ## Fields
  * `:id` - The unique id of the institution.
  * `:country` - The country where the institution is located.
  * `:bank_code` - The code of the institution in the country that the institution
  is located.
  * `:swift` - The SWIFT code that identifies a particular bank worldwide.
  * `:logo_url` - The url with the logo of the institution.
  * `:contact_id` - The unique id of contact that the institution refers. As an
  institution is a contact, this id must be informed. See `Cashtrail.Contacts.Contact`
  to know more about a contact.
  * `:contact` - The the contact that the institution refers.
  * `:inserted_at` - When the institution was inserted at the first time.
  * `:updated_at` - When the institution was updated at the last time.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Contacts

  @type t :: %Cashtrail.Banking.Institution{
          id: Ecto.UUID.t() | nil,
          country: String.t() | nil,
          bank_code: String.t() | nil,
          swift: String.t() | nil,
          logo_url: String.t() | nil,
          contact_id: Ecto.UUID.t() | nil,
          contact: Cashtrail.Contacts.Contact.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "institutions" do
    field :country, :string
    field :bank_code, :string
    field :logo_url, :string
    field :swift, :string

    belongs_to :contact, Contacts.Contact, on_replace: :update

    timestamps()
  end

  @url_regex ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)/
  @swift_regex ~r/[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?/i

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(institution, attrs) do
    institution
    |> cast(attrs, [:country, :bank_code, :swift, :logo_url, :contact_id])
    |> validate_format(:swift, @swift_regex, message: "is not a valid swift code")
    |> validate_format(:logo_url, @url_regex, message: "is not a valid url")
    |> ensure_associated_contact()
  end

  defp ensure_associated_contact(changeset) do
    if Ecto.Changeset.get_field(changeset, :contact_id) do
      changeset
    else
      cast_assoc(changeset, :contact, required: true)
    end
  end
end
