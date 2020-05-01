defmodule Cashtrail.Contacts.Contact do
  @moduledoc """
  It represents a contact of the application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Contacts.{Address, Category}

  @type t :: %Cashtrail.Contacts.Contact{
          id: Ecto.UUID.t() | nil,
          name: String.t() | nil,
          legal_name: String.t() | nil,
          tax_id: String.t() | nil,
          type: String.t() | nil,
          customer: boolean | nil,
          supplier: boolean | nil,
          phone: String.t() | nil,
          email: String.t() | nil,
          category: Ecto.Association.NotLoaded.t() | Category.t() | nil,
          category_id: Ecto.UUID.t() | nil,
          address: Address.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :name, :string
    field :legal_name, :string
    field :tax_id, :string
    field :type, :string, default: "company"
    field :customer, :boolean, default: false
    field :supplier, :boolean, default: false
    field :phone, :string
    field :email, :string

    embeds_one :address, Address, on_replace: :update
    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :legal_name, :tax_id, :type, :customer, :supplier, :phone, :email])
    |> validate_required([:name, :type])
    |> cast_embed(:address)
  end
end
