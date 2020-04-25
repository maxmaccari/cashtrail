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
          password: "some password",
          password_confirmation: "some password"
        })
        |> Accounts.create_user()

      users
    end

    def entity_fixture(attrs \\ %{}) do
      owner_id =
        case attrs do
          %{owner_id: id} ->
            id

          _ ->
            user_fixture(Map.get(attrs, :owner, %{})).id
        end

      {:ok, entity} =
        attrs
        |> Enum.into(%{@valid_attrs | owner_id: owner_id})
        |> Entities.create_entity()

      remove_owner(entity)
    end

    test "list_entities/0 returns all entities" do
      entity = entity_fixture()
      assert Entities.list_entities() == [entity]
    end

    test "list_entities_from/1 returns all entities from an user" do
      entity_fixture()
      owner = user_fixture(%{email: "john_doe_2@example.com"})
      entity_fixture(%{owner_id: owner.id})

      assert [%Entity{owner_id: owner_id}] = Entities.list_entities_from(owner)
      assert owner_id == owner.id
    end

    test "get_entity!/1 returns the entity with given id" do
      entity = entity_fixture()
      assert Entities.get_entity!(entity.id) == entity
    end

    test "create_entity/1 with valid data creates a entity" do
      user = user_fixture()

      assert {:ok, %Entity{} = entity} =
               @valid_attrs |> Map.put(:owner_id, user.id) |> Entities.create_entity()

      assert entity.name == "some name"
      assert entity.status == "active"
      assert entity.type == "personal"
      assert entity.owner_id == user.id
    end

    test "create_entity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entities.create_entity(@invalid_attrs)
    end

    test "update_entity/2 with valid data updates the entity" do
      entity = entity_fixture()
      assert {:ok, %Entity{} = entity} = Entities.update_entity(entity, @update_attrs)
      assert entity.name == "some updated name"
      assert entity.status == "archived"
      assert entity.type == "company"
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
