defmodule Cashtray.EntitiesTest do
  use Cashtray.DataCase

  alias Cashtray.{Accounts, Entities}

  describe "entities" do
    alias Cashtray.Entities.Entity

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
          %{owner: owner} ->
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

    test "create_entity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entities.create_entity(%Accounts.User{}, @invalid_attrs)
    end

    test "create_entity/1 with invalid user returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entities.create_entity(%Accounts.User{}, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Entities.create_entity(%Accounts.User{id: Ecto.UUID.generate()}, @valid_attrs)
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

    test "change_entity/1 returns a entity changeset" do
      entity = entity_fixture()
      assert %Ecto.Changeset{} = Entities.change_entity(entity)
    end
  end
end
