defmodule Cashtray.EntitiesTest do
  use Cashtray.DataCase

  alias Cashtray.{Accounts, Entities}

  describe "entities" do
    alias Cashtray.Entities.Entity
    alias Cashtray.Entities.EntityMember

    @valid_attrs %{name: "some name", status: "active", type: "personal", owner_id: nil}
    @update_attrs %{
      name: "some updated name",
      status: "archived",
      type: "company"
    }
    @invalid_attrs %{name: nil, status: nil, type: nil, owner_id: nil}

    def remove_owner(entity) do
      %{
        entity
        | owner: %Ecto.Association.NotLoaded{
            __cardinality__: :one,
            __field__: :owner,
            __owner__: Cashtray.Entities.Entity
          }
      }
    end

    defp user_fixture(attrs \\ %{}) do
      {:ok, users} =
        attrs
        |> Enum.into(%{
          email: "john_doe@example.com",
          first_name: "some first_name",
          last_name: "some last_name",
          password: "my_password123",
          password_confirmation: "my_password123"
        })
        |> Accounts.create_user()

      users
    end

    def entity_fixture(attrs \\ %{}) do
      owner =
        case attrs do
          %{owner: %Accounts.User{} = owner} ->
            owner

          _ ->
            user_fixture(Map.get(attrs, :owner, %{}))
        end

      attrs = Enum.into(attrs, @valid_attrs)
      {:ok, entity} = Entities.create_entity(owner, attrs)

      remove_owner(entity)
    end

    test "list_entities_from/1 returns all entities from an user that is owner" do
      entity_fixture()
      owner = user_fixture(%{email: "john_doe_2@example.com"})
      entity_fixture(%{owner: owner})

      assert [%Entity{owner_id: owner_id}] = Entities.list_entities_from(owner)
      assert owner_id == owner.id
    end

    test "list_entities_from/1 returns all entities from an user that is member" do
      entity = entity_fixture()
      user = user_fixture(%{email: "john_doe_2@example.com"})
      # TODO: change to use fixture or factory here
      Entities.add_member(entity, user)

      assert Entities.list_entities_from(user) == [entity]
    end

    test "get_entity!/1 returns the entity with given id" do
      entity = entity_fixture()
      assert Entities.get_entity!(entity.id) == entity
    end

    test "create_entity/1 with valid data creates a entity" do
      user = user_fixture()

      assert {:ok, %Entity{} = entity} = Entities.create_entity(user, @valid_attrs)

      assert entity.name == "some name"
      assert entity.status == "active"
      assert entity.type == "personal"
      assert entity.owner_id == user.id
    end

    test "create_entity/1 with valid data creates a prefix with the entity id" do
      user = user_fixture()

      assert {:ok, %Entity{} = entity} = Entities.create_entity(user, @valid_attrs)
      assert Triplex.exists?(entity.id)
    end

    test "create_entity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Entities.create_entity(%Accounts.User{}, @invalid_attrs)
    end

    test "create_entity/1 with invalid user returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entities.create_entity(%Accounts.User{}, @valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Entities.create_entity(%Accounts.User{id: Ecto.UUID.generate()}, @valid_attrs)
    end

    test "update_entity/2 with valid data updates the entity" do
      entity = entity_fixture()
      assert {:ok, %Entity{} = entity} = Entities.update_entity(entity, @update_attrs)
      assert entity.name == "some updated name"
      assert entity.status == "archived"
      assert entity.type == "company"
    end

    test "update_entity/2 does not allow to change the owner" do
      entity = entity_fixture()
      user = user_fixture(%{email: "john_doe2@example.com"})
      assert {:ok, %Entity{} = entity} = Entities.update_entity(entity, %{owner_id: user.id})
      assert entity.owner_id != user.id
    end

    test "update_entity/2 with invalid data returns error changeset" do
      entity = entity_fixture()
      assert {:error, %Ecto.Changeset{}} = Entities.update_entity(entity, @invalid_attrs)
      assert entity == Entities.get_entity!(entity.id)
    end

    test "delete_entity/1 deletes the entity" do
      entity = entity_fixture()
      assert {:ok, %Entity{}} = Entities.delete_entity(entity)
      assert_raise Ecto.NoResultsError, fn -> Entities.get_entity!(entity.id) end
    end

    test "delete_entity/1 deletes the entity tenant" do
      entity = entity_fixture()
      assert {:ok, %Entity{}} = Entities.delete_entity(entity)
      refute Triplex.exists?(entity.id)
    end

    test "change_entity/1 returns a entity changeset" do
      entity = entity_fixture()
      assert %Ecto.Changeset{} = Entities.change_entity(entity)
    end

    test "transfer_ownership/3 transfer ownership from an user to another" do
      from_user = user_fixture()
      entity = entity_fixture(%{owner: from_user})
      to_user = user_fixture(%{email: "john_doe2@example.com"})
      assert {:ok, %Entity{} = entity} = Entities.transfer_ownership(entity, from_user, to_user)
      assert entity.owner_id == to_user.id
    end

    test "transfer_ownership/3 fails if from user is not the owner" do
      entity = entity_fixture()
      user = user_fixture(%{email: "john_doe2@example.com"})
      assert {:error, :unauthorized} = Entities.transfer_ownership(entity, user, user)
    end

    test "transfer_ownership/3 fails if to user is invalid" do
      user = user_fixture()
      entity = entity_fixture(%{owner: user})

      assert {:error, %Ecto.Changeset{}} =
               Entities.transfer_ownership(entity, user, %Accounts.User{})

      assert {:error, %Ecto.Changeset{}} =
               Entities.transfer_ownership(
                 entity,
                 user,
                 %Accounts.User{id: Ecto.UUID.generate()}
               )
    end

    test "transfer_ownership/3 remove membership if the new owner was a member" do
      from_user = user_fixture()
      entity = entity_fixture(%{owner: from_user})
      to_user = user_fixture(%{email: "john_doe2@example.com"})
      # TODO: change to use fixture or factory here
      Entities.add_member(entity, to_user)
      assert {:ok, %Entity{} = entity} = Entities.transfer_ownership(entity, from_user, to_user)
      assert Entities.member_from_user(entity, to_user) == nil
    end

    test "transfer_ownership/3 sets the owner as a new member with admin privilegies" do
      from_user = user_fixture()
      entity = entity_fixture(%{owner: from_user})
      to_user = user_fixture(%{email: "john_doe2@example.com"})

      assert {:ok, %Entity{} = entity} = Entities.transfer_ownership(entity, from_user, to_user)
      assert %EntityMember{} = member = Entities.member_from_user(entity, from_user)
      assert member.user_id == from_user.id
      assert member.permission == "admin"
    end

    test "belongs_to?/2 checks if the entity belongs to user" do
      user = user_fixture()
      owner = user_fixture(%{email: "john_doe2@example.com"})
      entity = entity_fixture(%{owner: owner})

      assert Entities.belongs_to?(entity, owner)
      refute Entities.belongs_to?(entity, user)
    end
  end

  describe "entity_members" do
    alias Cashtray.Entities.EntityMember

    @user_attrs %{
      email: "john_doe_member@example.com",
      first_name: "john",
      last_name: "doe",
      password: "my_password123",
      password_confirmation: "my_password123"
    }
    @valid_attrs %{permission: "read", user: @user_attrs}
    @invalid_attrs %{permission: nil, user: %{email: "invalid"}}

    def remove_user(entity_member) do
      %{
        entity_member
        | user: %Ecto.Association.NotLoaded{
            __cardinality__: :one,
            __field__: :user,
            __owner__: Cashtray.Entities.EntityMember
          }
      }
    end

    def entity_member_fixture(attrs \\ %{}) do
      entity =
        case attrs do
          %{entity: %Entities.Entity{} = entity} ->
            entity

          _ ->
            entity_fixture(Map.get(attrs, :entity, %{}))
        end

      attrs = Enum.into(attrs, @valid_attrs)

      {:ok, entity_member} = Entities.create_member(entity, attrs)

      remove_user(entity_member)
    end

    test "list_members/1 returns all entity_members from the entity" do
      entity = entity_fixture(%{owner: %{@user_attrs | email: "doe@example.com"}})
      entity_member_fixture(%{@valid_attrs | user: %{@user_attrs | email: "john@example.com"}})
      entity_member = entity_member_fixture(%{entity: entity})
      assert Entities.list_members(entity) == [entity_member]
    end

    test "create_member/2 with valid data creates a entity_member with the user" do
      entity = entity_fixture()
      assert {:ok, %EntityMember{} = entity_member} = Entities.create_member(entity, @valid_attrs)
      assert entity_member.permission == "read"
      assert entity_member.user.email == "john_doe_member@example.com"
      assert entity_member.user.first_name == "john"
      assert entity_member.user.last_name == "doe"
    end

    test "create_member/2 with email from a created user create member with the user" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      assert {:ok, %EntityMember{} = entity_member} = Entities.create_member(entity, @valid_attrs)
      assert entity_member.permission == "read"
      assert entity_member.user_id == user.id
    end

    test "create_member/2 with invalid data returns error changeset" do
      entity = entity_fixture()
      assert {:error, %Ecto.Changeset{}} = Entities.create_member(entity, @invalid_attrs)
    end

    test "create_member/2 with same user returns error changeset" do
      entity = entity_fixture()
      assert {:ok, %EntityMember{} = entity_member} = Entities.create_member(entity, @valid_attrs)

      assert {:error, %Ecto.Changeset{errors: [entity_id: {"has already been added", _}]}} =
               Entities.create_member(entity, @valid_attrs)
    end

    test "add_member/2 adds a user as a member with 'read' permission" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      assert {:ok, %EntityMember{} = entity_member} = Entities.add_member(entity, user)
      assert entity_member.permission == "read"
    end

    test "add_member/3 adds a user as a member with the given permission" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      assert {:ok, %EntityMember{} = entity_member} = Entities.add_member(entity, user, "write")
      assert entity_member.permission == "write"
    end

    test "add_member/3 twice with the same user returns error changeset" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      assert {:ok, %EntityMember{} = entity_member} = Entities.add_member(entity, user)

      assert {:error, %Ecto.Changeset{errors: [entity_id: {"has already been added", _}]}} =
               Entities.add_member(entity, user)
    end

    test "remove_member/2 remove user as member of the entity not deleting the user" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity, user_id: user.id})

      assert {:ok, %EntityMember{}} = Entities.remove_member(entity, user)
      refute Repo.get_by(EntityMember, entity_id: entity.id, user_id: user.id)
      assert Cashtray.Accounts.get_user!(user.id)
    end

    test "remove_member/2 with a non member user returns error" do
      user = user_fixture(%{@user_attrs | email: "john@example.com"})
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity})

      assert {:error, :not_found} = Entities.remove_member(entity, user)
    end

    test "update_member_permission/3 updates the permission of the member" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity, user_id: user.id, permission: "read"})

      assert {:ok, %EntityMember{} = entity_member} =
               Entities.update_member_permission(entity, user, "write")

      assert entity_member.permission == "write"
    end

    test "update_member_permission/3 with invalid permission returns error" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity, user_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               Entities.update_member_permission(entity, user, "invalid")
    end

    test "update_member_permission/3 with a owner returns error" do
      user = user_fixture(%{@user_attrs | email: "john@example.com"})
      entity = entity_fixture(%{owner: user})
      entity_member_fixture(%{entity: entity})

      assert {:error, :invalid} = Entities.update_member_permission(entity, user, "write")
    end

    test "update_member_permission/3 with a non member user returns error" do
      user = user_fixture(%{@user_attrs | email: "john@example.com"})
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity})

      assert {:error, :not_found} = Entities.update_member_permission(entity, user, "write")
    end

    test "get_member_permission/2 returns the member permission as atom from the user" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity, user_id: user.id, permission: "read"})

      assert Entities.get_member_permission(entity, user) == :read
    end

    test "get_member_permission/2 when is owner returns :admin permission" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture(%{owner: user})

      assert Entities.get_member_permission(entity, user) == :admin
    end

    test "get_member_permission/2 returns :unauthorized if the user is not a member" do
      user = user_fixture(%{@user_attrs | email: "john@example.com"})
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity})

      assert Entities.get_member_permission(entity, user) == :unauthorized
    end

    test "get_member_from_user/2 return the member of the entity and the user" do
      user = user_fixture(@user_attrs)
      entity = entity_fixture()
      entity_member_fixture(%{entity: entity, user_id: user.id})

      %EntityMember{} = member = Entities.member_from_user(entity, user)
      assert member.entity_id == entity.id
      assert member.user_id == user.id
    end

    test "get_member_from_user/2 return the member nil if is not member or is the owner" do
      user = user_fixture(@user_attrs)
      owner = user_fixture(%{@user_attrs | email: "owner@example.com"})
      entity = entity_fixture(%{owner: owner})

      assert Entities.member_from_user(entity, user) == nil
      assert Entities.member_from_user(entity, owner) == nil
    end

    test "change_member/1 returns a entity_member changeset" do
      entity_member = entity_member_fixture()
      assert %Ecto.Changeset{} = Entities.change_member(entity_member)
    end
  end
end
