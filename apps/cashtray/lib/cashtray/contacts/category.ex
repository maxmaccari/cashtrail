defmodule Cashtray.Contacts.Category do
  @moduledoc """
  It represents a category of contacts in the application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtray.Contacts.Contact

  @type t :: %Cashtray.Contacts.Category{
          id: Ecto.UUID.t() | nil,
          description: String.t() | nil,
          contacts: Ecto.Association.NotLoaded.t() | list(Contact.t()) ,
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
