defmodule Cashtray.Factories.EntitiesFactory do
  alias Cashtray.Repo
  alias Cashtray.Accounts.User
  alias Cashtray.Entities.{Entity, EntityMember}
  alias Cashtray.Factories.AccountsFactory

  def entity_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "some name",
      status: "active",
      type: "personal",
      owner_id: nil
    })
  end

  def build_entity(attrs \\ %{}) do
    Repo.load(Entity, entity_attrs(attrs))
  end

  @not_loaded_owner %Ecto.Association.NotLoaded{
    __cardinality__: :one,
    __field__: :owner,
    __owner__: Cashtray.Entities.Entity
  }

  @not_loaded_members %Ecto.Association.NotLoaded{
    __cardinality__: :many,
    __field__: :members,
    __owner__: Cashtray.Entities.Entity
  }

  def insert_entity(attrs \\ %{}) do
    attrs
    |> build_entity()
    |> check_owner_id(attrs)
    |> Map.put(:owner, nil)
    |> Map.put(:members, [])
    |> Repo.insert!()
    |> Map.put(:owner, @not_loaded_owner)
    |> Map.put(:members, @not_loaded_members)
  end

  defp check_owner_id(struct, attrs) do
    case attrs do
      %{owner: %User{} = owner} ->
        Map.put(struct, :owner_id, owner.id)

      %{owner: owner} when is_map(owner) ->
        owner = AccountsFactory.insert_user(owner)

        Map.put(struct, :owner_id, owner.id)

      %{owner_id: owner_id} ->
        Map.put(struct, :owner_id, owner_id)

      _ ->
        owner = AccountsFactory.insert_user()

        Map.put(struct, :owner_id, owner.id)
    end
  end

  def entity_member_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      permission: "read"
    })
  end

  def build_entity_member(attrs \\ %{}) do
    Repo.load(EntityMember, entity_member_attrs(attrs))
  end

  @not_loaded_user %Ecto.Association.NotLoaded{
    __cardinality__: :one,
    __field__: :user,
    __owner__: Cashtray.Entities.EntityMember
  }

  @not_loaded_entity %Ecto.Association.NotLoaded{
    __cardinality__: :one,
    __field__: :entity,
    __owner__: Cashtray.Entities.EntityMember
  }

  defp check_user_id(struct, attrs) do
    case attrs do
      %{user: %User{} = user} ->
        Map.put(struct, :user_id, user.id)

      %{user: user} when is_map(user) ->
        user = AccountsFactory.insert_user(user)
        Map.put(struct, :user_id, user.id)

      %{user_id: user_id} ->
        Map.put(struct, :user_id, user_id)

      _ ->
        user = AccountsFactory.insert_user()
        Map.put(struct, :user_id, user.id)
    end
  end

  defp check_entity_id(struct, attrs) do
    case attrs do
      %{entity: %Entity{} = entity} ->
        Map.put(struct, :entity_id, entity.id)

      %{entity: entity} when is_map(entity) ->
        entity = insert_entity(entity)

        Map.put(struct, :entity_id, entity.id)

      %{entity_id: entity_id} ->
        Map.put(struct, :entity_id, entity_id)

      _ ->
        entity = insert_entity()

        Map.put(struct, :entity_id, entity.id)
    end
  end

  def insert_entity_member(attrs \\ %{}) do
    attrs
    |> build_entity_member()
    |> check_user_id(attrs)
    |> check_entity_id(attrs)
    |> Map.put(:entity, nil)
    |> Map.put(:user, nil)
    |> Repo.insert!()
    |> Map.put(:entity, @not_loaded_entity)
    |> Map.put(:user, @not_loaded_user)
  end
end
