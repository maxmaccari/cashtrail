defmodule Cashtrail.Entities.EntityMember do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a member of a
  `Cashtrail.Entity` that links authorized users to the `Cashtrail.Entity`,
  except the owner.

  The EntityMember is a member of the entity. As a member of the entity, the user
  can have permission to read, create and update records, or even admin the entity.

  The owner cannot be a member of the `Cashtrail.Entity`.

  ## Fields

  * `:id` - The unique id of the entity member.
  * `:permission` - The permission of the entity member. The permissions can be:
    * `:read` - With this permission, the member can read the data from the entity.
    * `:write` - With this permission, the member can read, create, modify, and
    delete data from the entity, except change the entity settings or manage the
    members of the entity.
    * `:admin` - With this permission, the member can have all permissions from write,
    change the settings, and manage the members of the entity.
  * `:entity` - The entity that the member is part of, related to `Cashtrail.Entities.Entity`.
  * `:entity_id` - The id of the entity that the member is part of.
  * `:user` - The user that is a member of the entity, related to `Cashtrail.Users.User`.
  * `:user_id` - The id of the user that is member of the entity.
  * `:inserted_at` - When the entity member was inserted at the first time.
  * `:updated_at` - When the entity member was updated at the last time.

  See `Cashtrail.Entities` to know how to list, get, insert, update, and delete
  entity members.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.{Entities, Users}

  @type permission :: :admin | :read | :write

  @type t :: %Cashtrail.Entities.EntityMember{
          id: Ecto.UUID.t() | nil,
          permission: permission() | nil,
          entity_id: Ecto.UUID.t() | nil,
          entity: Ecto.Association.NotLoaded.t() | Entities.Entity.t() | nil,
          user_id: Ecto.UUID.t() | nil,
          user: Ecto.Association.NotLoaded.t() | Users.User.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entity_members" do
    field :permission, Ecto.Enum, values: [:read, :write, :admin]
    belongs_to :entity, Entities.Entity
    belongs_to :user, Users.User

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  def changeset(entity_member, attrs) do
    entity_member
    |> cast(attrs, [:permission, :user_id])
    |> validate_required([:permission])
    |> cast_assoc(:user)
    |> unique_constraint([:entity_id, :user_id], message: "has already been added")
    |> foreign_key_constraint(:entity_id)
    |> foreign_key_constraint(:user_id)
  end
end
