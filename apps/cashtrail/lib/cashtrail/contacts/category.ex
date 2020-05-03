defmodule Cashtrail.Contacts.Category do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a category of one contact and
  the entity.

  **Warning**: Don't use the functions of this module. Only use this module as a
  struct to represent a category. The functions of this module are internal and
  can change over time. Only manipulate categories through the
  `Cashtrail.Contacts` that is the context for this.

  The category is a way to divide your contacts that have shared characteristics.
  You may want to divide your contacts into "Friends", "Family", "Store",
  "Restaurant", "Bank" and whatever category you want. This can be used to generate
  reports or to know how much money your spend in "Restaurants", for instance.

  ## Fields

  * `:id` - The unique id of the category.
  * `:description` - The description of the category.
  * `:contacts` - The contacts that references to this category.
  * `:inserted_at` - When the category was inserted at the first time.
  * `:updated_at` - When the category was updated at the last time.

  See `Cashtrail.Contacts` to know how to list, get, insert, update, and delete contact categories.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Contacts.Contact

  @type t :: %Cashtrail.Contacts.Category{
          id: Ecto.UUID.t() | nil,
          description: String.t() | nil,
          contacts: Ecto.Association.NotLoaded.t() | list(Contact.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_categories" do
    field :description, :string
    has_many :contacts, Contact

    timestamps()
  end

  @spec changeset(t | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> unique_constraint(:description)
  end
end
