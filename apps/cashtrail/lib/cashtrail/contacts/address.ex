defmodule Cashtrail.Contacts.Address do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents an address of the contact.

  **Warning**: Don't use the functions of this module. Only use this module as a
  struct to represent an address. The functions of this module are internal and
  can change over time. Only manipulate addresses through the `Cashtrail.Contacts`
  that is the context for this.

  The address is stored in a `json` field of the contact, and not in a specific
  table in the database. This struct is used to force the address to a specific
  schema in this json field.

  Each country has their own type of address. So, no fields are required. You
  can choose allow only to fill `:line_1` and `:line_2` in your frontend,
  or allow fill the other fields instead.

  ## Fields

  * `:id` - The unique id of the address.
  * `:street` - street part of the address.
  * `:number` - number part of the address.
  * `:complement` - complement part of the address, like apartment number for instance.
  * `:district` - district part of the address.
  * `:city` - city part of the address.
  * `:state` - state or province part of the address. This depends of the country.
  * `:country` - The country of the address.
  * `:zip` - The zip code of the address. This field is not validated, so you can
  insert whathever the zip code of any country you want.
  * `:line_1` - The line 1 can have the street and number in some countries (like in the US).
  * `:line_2` - The line 2 can have the city, state and zip code in some countries (like in the US).

  See `Cashtrail.Contacts.create_contact/2` to know how to create a contact with an address, or
  `Cashtrail.Contacts.create_contact/2` to know how to update an address of a contact, ir
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
    field :street
    field :number
    field :complement
    field :district
    field :city
    field :state
    field :country
    field :zip
    field :line_1
    field :line_2
  end

  @doc false
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
