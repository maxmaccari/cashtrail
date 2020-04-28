defmodule Cashtray.Contacts.Category do
  @moduledoc """
  It represents a category of contacts in the application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtray.Contacts.Category{
          id: Ecto.UUID.t() | nil,
          description: String.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_categories" do
    field :description, :string

    timestamps()
  end

  @spec changeset(t | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> validate_length(:description, min: 1)
  end
end