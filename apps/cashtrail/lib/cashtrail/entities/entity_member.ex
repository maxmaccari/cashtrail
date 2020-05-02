defmodule Cashtrail.Entities.EntityMember do
  @moduledoc """
  Represents a member of an `Cashtrail.Entity` that links authorized users to the
  `Cashtrail.Entity`, except the owner.

  The owner cannot be a member of the `Cashtrail.Entity`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Users.User
  alias Cashtrail.Entities.Entity

  @type t() :: %Cashtrail.Entities.EntityMember{
          id: Ecto.UUID.t() | nil,
          permission: String.t() | nil,
          entity_id: Ecto.UUID.t() | nil,
          entity: Ecto.Association.NotLoaded.t() | Entity.t() | nil,
          user_id: Ecto.UUID.t() | nil,
          user: Ecto.Association.NotLoaded.t() | User.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entity_members" do
    field :permission, :string
    belongs_to :entity, Entity
    belongs_to :user, User

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  def changeset(entity_member, attrs) do
    entity_member
    |> cast(attrs, [:permission, :user_id])
    |> validate_required([:permission])
    |> validate_inclusion(:permission, ["read", "write", "admin"])
    |> cast_assoc(:user)
    |> unique_constraint([:entity_id, :user_id], message: "has already been added")
    |> foreign_key_constraint(:entity_id)
    |> foreign_key_constraint(:user_id)
  end
end
