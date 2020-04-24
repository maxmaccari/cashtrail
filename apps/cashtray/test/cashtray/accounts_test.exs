defmodule Cashtray.AccountsTest do
  use Cashtray.DataCase

  alias Cashtray.Accounts

  describe "users" do
    alias Cashtray.Accounts.User

    @valid_attrs %{
      email: "some email",
      first_name: "some first_name",
      last_name: "some last_name",
      password: "some password",
      password_confirmation: "some password"
    }
    @update_attrs %{
      email: "some updated email",
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      password: "updated password",
      password_confirmation: "updated password"
    }
    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      %{user | password: nil}
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = %{password_hash: old_password_hash} = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.password_hash != old_password_hash
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "entities" do
    alias Cashtray.Accounts.Entity

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
            __owner__: Cashtray.Accounts.Entity
          }
      }
    end

    def entity_fixture(attrs \\ %{}) do
      user = user_fixture()

      {:ok, entity} =
        attrs
        |> Enum.into(%{@valid_attrs | owner_id: user.id})
        |> Accounts.create_entity()

      remove_owner(entity)
    end

    test "list_entities/0 returns all entities" do
      entity = entity_fixture()
      assert Accounts.list_entities() == [entity]
    end

    test "get_entity!/1 returns the entity with given id" do
      entity = entity_fixture()
      assert Accounts.get_entity!(entity.id) == entity
    end

    test "create_entity/1 with valid data creates a entity" do
      user = user_fixture()

      assert {:ok, %Entity{} = entity} =
               @valid_attrs |> Map.put(:owner_id, user.id) |> Accounts.create_entity()

      assert entity.name == "some name"
      assert entity.status == "active"
      assert entity.type == "personal"
      assert entity.owner_id == user.id
    end

    test "create_entity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_entity(@invalid_attrs)
    end

    test "update_entity/2 with valid data updates the entity" do
      entity = entity_fixture()
      assert {:ok, %Entity{} = entity} = Accounts.update_entity(entity, @update_attrs)
      assert entity.name == "some updated name"
      assert entity.status == "archived"
      assert entity.type == "company"
    end

    test "update_entity/2 with invalid data returns error changeset" do
      entity = entity_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_entity(entity, @invalid_attrs)
      assert entity == Accounts.get_entity!(entity.id)
    end

    test "delete_entity/1 deletes the entity" do
      entity = entity_fixture()
      assert {:ok, %Entity{}} = Accounts.delete_entity(entity)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_entity!(entity.id) end
    end

    test "change_entity/1 returns a entity changeset" do
      entity = entity_fixture()
      assert %Ecto.Changeset{} = Accounts.change_entity(entity)
    end
  end
end
