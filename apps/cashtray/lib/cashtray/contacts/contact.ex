defmodule Cashtray.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :category_id, :binary_id
    field :name, :string
    field :legal_name, :string
    field :tax_id, :string
    field :type, :string
    field :customer, :boolean, default: false
    field :supplier, :boolean, default: false
    field :phone, :string
    field :email, :string
    field :address, :map

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :legal_name, :tax_id, :type, :customer, :supplier, :phone, :email, :address])
    |> validate_required([:name, :type])
  end
end
