defmodule Cashtray.EntitiesTest do
  @moduledoc false

  use Cashtray.DataCase, async: true

  alias Cashtray.{Accounts, Entities}

  describe "entities" do
    alias Cashtray.Entities.Entity
    alias Cashtray.Entities.EntityMember

    test "list_entities/1 returns all entities" do
      entity = insert(:entity) |> forget(:owner)
      assert Entities.list_entities().entries == [entity]
    end

    test "list_entities/1 works with pagination" do
      entities =
        insert_list(25, :entity)
        |> Enum.slice(20, 5)
        |> Enum.map(&forget(&1, :owner))

      assert Entities.list_entities(page: 2) == %Cashtray.Paginator.Page{
               entries: entities,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_entities/1 filtering by type" do
      insert(:entity, type: "personal") |> forget(:owner)
      entity = insert(:entity, type: "company") |> forget(:owner)
      assert Entities.list_entities(filter: %{type: "company"}).entries == [entity]
      assert Entities.list_entities(filter: %{"type" => "company"}).entries == [entity]
    end

    test "list_entities/1 filtering by status" do
      insert(:entity, status: "active")
      entity = insert(:entity, status: "archived") |> forget(:owner)
      assert Entities.list_entities(filter: %{status: "archived"}).entries == [entity]
      assert Entities.list_entities(filter: %{"status" => "archived"}).entries == [entity]
    end

    test "list_entities/1 filtering by invalid key" do
      entity = insert(:entity, type: "company") |> forget(:owner)
      assert Entities.list_entities(filter: %{invalid: nil}).entries == [entity]
    end

    test "list_entities/1 searching by name" do
      insert(:entity, name: "abc")
      entity = insert(:entity, name: "defghij") |> forget(:owner)
      assert Entities.list_entities(search: "fgh").entries == [entity]
    end

    test "list_entities_from/2 returns all entities from an user that is owner" do
      insert(:entity)
      owner = insert(:user)
      entity = insert(:entity, owner: owner) |> forget(:owner)

      assert Entities.list_entities_from(owner).entries == [entity]
    end

    test "list_entities_from/2 returns all entities from an user that is member" do
      entity = insert(:entity) |> forget(:owner)
      user = insert(:user)
      insert(:entity_member, entity: entity, user: user)

      assert Entities.list_entities_from(user).entries == [entity]
    end

    test "list_entities_from/2 works with pagination" do
      owner = insert(:user)

      insert_list(25, :entity, owner: owner)
      |> Enum.slice(20, 5)
      |> Enum.map(&forget(&1, :owner))

      assert %Cashtray.Paginator.Page{
               entries: entities,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             } = Entities.list_entities_from(owner, page: 2)

      assert length(entities) == 5
    end

    test "list_entities_from/2 filtering by type" do
      insert(:entity, type: "personal") |> forget(:owner)
      entity = insert(:entity, type: "company") |> forget(:owner)
      assert Entities.list_entities(filter: %{type: "company"}).entries == [entity]
      assert Entities.list_entities(filter: %{"type" => "company"}).entries == [entity]
    end

    test "list_entities_from/2 filtering by status" do
      insert(:entity, status: "active")
      entity = insert(:entity, status: "archived") |> forget(:owner)
      assert Entities.list_entities(filter: %{status: "archived"}).entries == [entity]
      assert Entities.list_entities(filter: %{"status" => "archived"}).entries == [entity]
    end

    test "list_entities_from/2 filtering by invalid key" do
      entity = insert(:entity, type: "company") |> forget(:owner)
      assert Entities.list_entities(filter: %{invalid: nil}).entries == [entity]
    end

    test "list_entities_from/2 searching by name" do
      insert(:entity, name: "abc")
      entity = insert(:entity, name: "defghij") |> forget(:owner)
      assert Entities.list_entities(search: "fgh").entries == [entity]
    end

    test "get_entity!/2 returns the entity with given id" do
      entity = insert(:entity) |> forget(:owner)
      assert Entities.get_entity!(entity.id) == entity
    end

    test "create_entity/2 with valid data creates a entity" do
      user = insert(:user)
      entity_params = params_for(:entity)
      assert {:ok, %Entity{} = entity} = Entities.create_entity(user, entity_params, false)

      assert entity.name == entity_params.name
      assert entity.status == entity_params.status
      assert entity.type == entity_params.type
      assert entity.owner_id == user.id
    end

    @invalid_attrs %{name: nil, status: nil, type: nil, owner_id: nil}
    test "create_entity/3 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Entities.create_entity(%Accounts.User{}, @invalid_attrs, false)
    end

    test "create_entity/3 with invalid user returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Entities.create_entity(%Accounts.User{}, params_for(:entity), false)

      assert {:error, %Ecto.Changeset{}} =
               Entities.create_entity(
                 %Accounts.User{id: Ecto.UUID.generate()},
                 params_for(:entity),
                 false
               )
    end

    @update_attrs %{
      name: "some updated name",
      status: "archived",
      type: "company"
    }
    test "update_entity/2 with valid data updates the entity" do
      entity = insert(:entity)
      assert {:ok, %Entity{} = entity} = Entities.update_entity(entity, @update_attrs)
      assert entity.name == "some updated name"
      assert entity.status == "archived"
      assert entity.type == "company"
    end

    test "update_entity/2 does not allow to change the owner" do
      entity = insert(:entity)
      user = insert(:user)
      assert {:ok, %Entity{} = entity} = Entities.update_entity(entity, %{owner_id: user.id})
      assert entity.owner_id != user.id
    end

    test "update_entity/2 with invalid data returns error changeset" do
      entity = insert(:entity) |> forget(:owner)
      assert {:error, %Ecto.Changeset{}} = Entities.update_entity(entity, @invalid_attrs)
      assert entity == Entities.get_entity!(entity.id)
    end

    test "delete_entity/1 deletes the entity" do
      {:ok, entity} = insert(:user) |> Entities.create_entity(params_for(:entity), false)
      assert {:ok, %Entity{}} = Entities.delete_entity(entity, false)
      assert_raise Ecto.NoResultsError, fn -> Entities.get_entity!(entity.id) end
    end

    test "change_entity/1 returns a entity changeset" do
      entity = insert(:entity)
      assert %Ecto.Changeset{} = Entities.change_entity(entity)
    end

    test "transfer_ownership/3 transfer ownership from an user to another" do
      entity = insert(:entity)
      to_user = insert(:user)

      assert {:ok, %Entity{} = entity} =
               Entities.transfer_ownership(entity, entity.owner, to_user)

      assert entity.owner_id == to_user.id
    end

    test "transfer_ownership/3 fails if from user is not the owner" do
      entity = insert(:entity)
      user = insert(:user)
      assert {:error, :unauthorized} = Entities.transfer_ownership(entity, user, user)
    end

    test "transfer_ownership/3 fails if to user is invalid" do
      entity = insert(:entity)

      assert {:error, %Ecto.Changeset{}} =
               Entities.transfer_ownership(entity, entity.owner, %Accounts.User{})

      assert {:error, %Ecto.Changeset{}} =
               Entities.transfer_ownership(
                 entity,
                 entity.owner,
                 %Accounts.User{id: Ecto.UUID.generate()}
               )
    end

    test "transfer_ownership/3 remove membership if the new owner was a member" do
      entity = insert(:entity)
      to_user = insert(:user)
      insert(:entity_member, entity: entity, user: to_user)

      assert {:ok, %Entity{} = entity} =
               Entities.transfer_ownership(entity, entity.owner, to_user)

      assert Entities.member_from_user(entity, to_user) == nil
    end

    test "transfer_ownership/3 sets the owner as a new member with admin privilegies" do
      from_user = insert(:user)
      entity = insert(:entity, owner: from_user)
      to_user = insert(:user)

      assert {:ok, %Entity{} = entity} = Entities.transfer_ownership(entity, from_user, to_user)
      assert %EntityMember{} = member = Entities.member_from_user(entity, from_user)
      assert member.user_id == from_user.id
      assert member.permission == "admin"
    end

    test "belongs_to?/2 checks if the entity belongs to user" do
      user = insert(:user)
      entity = insert(:entity)

      assert Entities.belongs_to?(entity, entity.owner)
      refute Entities.belongs_to?(entity, user)
    end
  end

  describe "entity_members" do
    alias Cashtray.Entities.{Entity, EntityMember}

    test "list_members/2 returns all entity_members from the entity" do
      insert(:entity_member)
      entity = insert(:entity)

      entity_member =
        insert(:entity_member, entity: entity)
        |> forget(:user)
        |> forget(:entity)

      assert Entities.list_members(entity).entries == [entity_member]
    end

    test "create_member/2 with valid data creates a entity_member with the user" do
      entity = insert(:entity)

      user_attrs = params_for(:user, password: "@abc1234")
      entity_member_attrs = params_for(:entity_member) |> Map.put(:user, user_attrs)

      assert {:ok, %EntityMember{} = entity_member} =
               Entities.create_member(entity, entity_member_attrs)

      assert entity_member.permission == entity_member_attrs.permission
      assert entity_member.user.email == user_attrs.email
      assert entity_member.user.first_name == user_attrs.first_name
      assert entity_member.user.last_name == user_attrs.last_name
    end

    test "create_member/2 with email from a created user create member with the user" do
      user = insert(:user)
      entity = insert(:entity)

      assert {:ok, %EntityMember{} = entity_member} =
               Entities.create_member(entity, %{
                 user: %{
                   email: user.email
                 },
                 permission: "read"
               })

      assert entity_member.permission == "read"
      assert entity_member.user_id == user.id
    end

    @invalid_attrs %{permission: nil, user: %{email: "invalid"}}
    test "create_member/2 with invalid data returns error changeset" do
      entity = insert(:entity)
      assert {:error, %Ecto.Changeset{}} = Entities.create_member(entity, @invalid_attrs)
    end

    test "create_member/2 with same user returns error changeset" do
      entity = insert(:entity)

      entity_member_attrs =
        params_for(:entity_member) |> Map.put(:user, params_for(:user, password: "@abc1234"))

      assert {:ok, %EntityMember{} = entity_member} =
               Entities.create_member(entity, entity_member_attrs)

      assert {:error, %Ecto.Changeset{errors: [entity_id: {"has already been added", _}]}} =
               Entities.create_member(entity, entity_member_attrs)
    end

    test "add_member/2 adds a user as a member with 'read' permission" do
      user = insert(:user)
      entity = insert(:entity)
      assert {:ok, %EntityMember{} = entity_member} = Entities.add_member(entity, user)
      assert entity_member.permission == "read"
    end

    test "add_member/3 adds a user as a member with the given permission" do
      user = insert(:user)
      entity = insert(:entity)
      assert {:ok, %EntityMember{} = entity_member} = Entities.add_member(entity, user, "write")
      assert entity_member.permission == "write"
    end

    test "add_member/3 twice with the same user returns error changeset" do
      user = insert(:user)
      entity = insert(:entity)
      assert {:ok, %EntityMember{} = entity_member} = Entities.add_member(entity, user)

      assert {:error, %Ecto.Changeset{errors: [entity_id: {"has already been added", _}]}} =
               Entities.add_member(entity, user)
    end

    test "add_member/3 with the owner user returns :invalid error" do
      entity = insert(:entity)
      assert {:error, :invalid} = Entities.add_member(entity, entity.owner)
    end

    test "remove_member/2 remove user as member of the entity not deleting the user" do
      member = insert(:entity_member)

      assert {:ok, %EntityMember{}} = Entities.remove_member(member.entity, member.user)

      refute Repo.get_by(EntityMember, entity_id: member.entity_id, user_id: member.user_id)
      assert Cashtray.Accounts.get_user!(member.user_id)
    end

    test "remove_member/2 with a non member user returns error" do
      user = insert(:user)
      entity = insert(:entity)
      insert(:entity_member, entity: entity)

      assert {:error, :not_found} = Entities.remove_member(entity, user)
    end

    test "update_member_permission/3 updates the permission of the member" do
      member = insert(:entity_member, permission: "read")

      assert {:ok, %EntityMember{} = entity_member} =
               Entities.update_member_permission(member.entity, member.user, "write")

      assert entity_member.permission == "write"
    end

    test "update_member_permission/3 with invalid permission returns error" do
      member = insert(:entity_member)

      assert {:error, %Ecto.Changeset{}} =
               Entities.update_member_permission(member.entity, member.user, "invalid")
    end

    test "update_member_permission/3 with a owner returns error" do
      member = insert(:entity_member)

      assert {:error, :invalid} =
               Entities.update_member_permission(member.entity, member.entity.owner, "write")
    end

    test "update_member_permission/3 with a non member user returns error" do
      user = insert(:user)
      member = insert(:entity_member)

      assert {:error, :not_found} =
               Entities.update_member_permission(member.entity, user, "write")
    end

    test "get_member_permission/2 returns the member permission as atom from the user" do
      member = insert(:entity_member, permission: "read")

      assert Entities.get_member_permission(member.entity, member.user) == :read
    end

    test "get_member_permission/2 when is owner returns :admin permission" do
      entity = insert(:entity)

      assert Entities.get_member_permission(entity, entity.owner) == :admin
    end

    test "get_member_permission/2 returns :unauthorized if the user is not a member" do
      user = insert(:user)
      member = insert(:entity_member)

      assert Entities.get_member_permission(member.entity, user) == :unauthorized
    end

    test "get_member_from_user/2 return the member of the entity and the user" do
      member = insert(:entity_member)

      %EntityMember{} = result = Entities.member_from_user(member.entity, member.user)
      assert result.entity_id == member.entity_id
      assert result.user_id == member.user_id
    end

    test "get_member_from_user/2 return the member nil if is not member or is the owner" do
      user = insert(:user)
      entity = insert(:entity)

      assert Entities.member_from_user(entity, user) == nil
      assert Entities.member_from_user(entity, entity.owner) == nil
    end

    test "change_member/1 returns a entity_member changeset" do
      entity_member = insert(:entity_member)
      assert %Ecto.Changeset{} = Entities.change_member(entity_member)
    end
  end
end
