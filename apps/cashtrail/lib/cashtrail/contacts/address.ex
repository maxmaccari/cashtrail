defmodule Cashtrail.Contacts.Address do
  @moduledoc """
  It represents a contact address of the application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtrail.Contacts.Address{
          id: Ecto.UUID.t() | nil,
          street: String.t() | nil,
          number: String.t() | nil,
          line_1: String.t() | nil,
          line_2: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          country: String.t() | nil,
          zip: String.t() | nil
        }

  embedded_schema do
    field :street
    field :number
    field :line_1
    field :line_2
    field :city
    field :state
    field :country
    field :zip
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:street, :number, :line_1, :line_2, :city, :state, :country, :zip])
  end
end
