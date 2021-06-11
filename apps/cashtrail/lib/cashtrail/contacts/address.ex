defmodule Cashtrail.Contacts.Address do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents an address of the contact.

  ## Fields

  * `:id` - The unique id of the address.
  * `:street` - street part of the address.
  * `:number` - number part of the address.
  * `:complement` - complement part of the address, like apartment number for instance.
  * `:district` - district part of the address.
  * `:city` - city part of the address.
  * `:state` - state or province part of the address. This depends on the country.
  * `:country` - The country of the address.
  * `:zip` - The zip code of the address. This field is not validated, so you can
  insert whatever the zip code of any country you want.
  * `:line_1` - Line 1 can have the street and number in some countries (like in the US).
  * `:line_2` - Line 2 can have the city, state, and zip code in some countries (like in the US).

  See `Cashtrail.Contacts.create_contact/2` to know how to create a contact with an address, or
  `Cashtrail.Contacts.create_contact/2` to know how to update an address of a contact, or
  insert a new one.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtrail.Contacts.Address{
          id: Ecto.UUID.t() | nil,
          street: String.t() | nil,
          number: String.t() | nil,
          complement: String.t() | nil,
          district: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          country: String.t() | nil,
          zip: String.t() | nil,
          line_1: String.t() | nil,
          line_2: String.t() | nil
        }

  embedded_schema do
    field :street, :string
    field :number, :string
    field :complement, :string
    field :district, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip, :string
    field :line_1, :string
    field :line_2, :string
  end

  @doc false
  @spec changeset(t | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [
      :street,
      :number,
      :complement,
      :district,
      :city,
      :state,
      :country,
      :zip,
      :line_1,
      :line_2
    ])
  end
end
