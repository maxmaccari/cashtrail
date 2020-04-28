defmodule Cashtray.ContactsTest do
  use Cashtray.DataCase

  alias Cashtray.Contacts

  setup_all do
    Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

    uuid = Ecto.UUID.generate()
    tenant = %Cashtray.Entities.Entity{id: uuid}

    Cashtray.Entities.Tenants.create(tenant)

    on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

      Cashtray.Entities.Tenants.drop(tenant)

      Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :manual)
    end)

    Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :manual)

    {:ok, [entity: tenant]}
  end

  describe "categories" do
    alias Cashtray.Contacts.Category

    test "list_categories/2 returns all categories", %{entity: entity} do
      category = insert(:contact_category, entity: entity)
      assert Contacts.list_categories(entity).entries == [category]
    end

    test "get_category!/2 returns the category with given id", %{entity: entity} do
      category = insert(:contact_category, entity: entity)

      assert Contacts.get_category!(entity, category.id) == category
    end

    test "create_category/2 with valid data creates a category", %{entity: entity} do
      category_params = params_for(:contact_category, entity: entity)
      assert {:ok, %Category{} = category} = Contacts.create_category(entity, category_params)
      assert category.description == category_params.description
    end

    @invalid_attrs %{description: nil}
    test "create_category/2 with invalid data returns error changeset", %{entity: entity} do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_category(entity, @invalid_attrs)
    end

    @update_attrs %{description: "some updated description"}
    test "update_category/2 with valid data updates the category", %{entity: entity} do
      category = insert(:contact_category, entity: entity)
      assert {:ok, %Category{} = category} = Contacts.update_category(category, @update_attrs)
      assert category.description == "some updated description"
    end

    test "update_category/2 with invalid data returns error changeset", %{entity: entity} do
      category = insert(:contact_category, entity: entity)
      assert {:error, %Ecto.Changeset{}} = Contacts.update_category(category, @invalid_attrs)
      assert category == Contacts.get_category!(entity, category.id)
    end

    test "delete_category/1 deletes the category", %{entity: entity} do
      category = insert(:contact_category, entity: entity)
      assert {:ok, %Category{}} = Contacts.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_category!(entity, category.id) end
    end

    test "change_category/1 returns a category changeset", %{entity: entity} do
      category = insert(:contact_category, entity: entity)
      assert %Ecto.Changeset{} = Contacts.change_category(category)
    end
  end
end
