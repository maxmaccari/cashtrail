defmodule Cashtrail.Contacts.Contact do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a contact of the entity.

  ## Definition

  According to the [BusinessDictionary.com](http://www.businessdictionary.com/definition/contact.html),
  this term can be used to describe reaching out to or being in touch with another
  person, business, or entity. So you can use this module to relate transactions to
  a person, business, or entity only to know who you received money from or to whom
  you paid some money, and contact them if necessary.

  ## Fields

  * `:id` - The unique id of the contact.
  * `:name` - This is the name that you refer to the contact. It can be the most know
  name of the contact, like the trade name of the company, or a nickname by which
  the person is well known.
  * `:type` - The type of contact. This can be:
    * `:company` - Used if the contact is a company. This is the default value if
    no type is chosen
    * `:person` - Used if the contact is an individual.
  * `:legal_name` - This is the name of register in government agencies. This can
  be the registered name of people or the legal name of companies.
  * `:tax_id` - This is a number used by governments to as unique identifier of
  individuals, be a person, be a company.
  * `:customer` - Says if this contact is a customer. It can be used to filter data.
  * `:supplier` - Says if this contact is a supplier. It can be used to filter data.
  * `:email` - The email of the contact.
  * `:phone` - The phone number of the contact. This field can receive and represents
  any phone number format.
  * `:category` - The category of the contact, which is related to `Cashtrail.Contacts.Category`.
  * `:category_id` - The id of the category witch the contact belongs to.
  * `:address` - The address of the contact, represented by the `Cashtrail.Contacts.Address`
  struct.
  * `:inserted_at` - When the contact was inserted at the first time.
  * `:updated_at` - When the contact was updated at the last time.

  See `Cashtrail.Contacts` to know how to list, get, insert, update, and delete contacts.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Contacts

  @type type :: :company | :person
  @type t :: %Cashtrail.Contacts.Contact{
          id: Ecto.UUID.t() | nil,
          name: String.t() | nil,
          type: type() | nil,
          legal_name: String.t() | nil,
          tax_id: String.t() | nil,
          customer: boolean | nil,
          supplier: boolean | nil,
          email: String.t() | nil,
          phone: String.t() | nil,
          category: Ecto.Association.NotLoaded.t() | Contacts.Category.t() | nil,
          category_id: Ecto.UUID.t() | nil,
          address: Contacts.Address.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :name, :string
    field :type, Ecto.Enum, values: [:company, :person], default: :company
    field :legal_name, :string
    field :tax_id, :string
    field :customer, :boolean, default: false
    field :supplier, :boolean, default: false
    field :email, :string
    field :phone, :string

    embeds_one :address, Contacts.Address, on_replace: :update
    belongs_to :category, Contacts.Category

    timestamps()
  end

  @doc false
  @spec changeset(t | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [
      :name,
      :legal_name,
      :tax_id,
      :type,
      :customer,
      :supplier,
      :phone,
      :email,
      :category_id
    ])
    |> validate_required([:name, :type])
    |> cast_embed(:address)
    |> foreign_key_constraint(:category_id)
  end
end
