defmodule Cashtray.Entities.EntityMember do
  @moduledoc """
  Represents a member of an Entity that links authorized users to the Entity,
  except the owner.

  The owner is not a member of the Entity.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtray.Accounts.User
  alias Cashtray.Entities.Entity

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entity_members" do
    field :permission, :string
    belongs_to :entity, Entity
    belongs_to :user, User

    timestamps()
  end

  @doc false
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
