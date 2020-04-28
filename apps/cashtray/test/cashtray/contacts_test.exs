defmodule Cashtray.ContactsTest do
  use Cashtray.TenantCase

  alias Cashtray.Contacts

  describe "categories" do
    alias Cashtray.Contacts.Category

    test "list_categories/2 returns all categories", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)
      assert Contacts.list_categories(tenant).entries == [category]
    end

    test "get_category!/2 returns the category with given id", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)

      assert Contacts.get_category!(tenant, category.id) == category
    end

    test "create_category/2 with valid data creates a category", %{tenant: tenant} do
      category_params = params_for(:contact_category, tenant: tenant)
      assert {:ok, %Category{} = category} = Contacts.create_category(tenant, category_params)
      assert category.description == category_params.description
    end

    @invalid_attrs %{description: nil}
    test "create_category/2 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_category(tenant, @invalid_attrs)
    end

    @update_attrs %{description: "some updated description"}
    test "update_category/2 with valid data updates the category", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)
      assert {:ok, %Category{} = category} = Contacts.update_category(category, @update_attrs)
      assert category.description == "some updated description"
    end

    test "update_category/2 with invalid data returns error changeset", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)
      assert {:error, %Ecto.Changeset{}} = Contacts.update_category(category, @invalid_attrs)
      assert category == Contacts.get_category!(tenant, category.id)
    end

    test "delete_category/1 deletes the category", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)
      assert {:ok, %Category{}} = Contacts.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_category!(tenant, category.id) end
    end

    test "change_category/1 returns a category changeset", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)
      assert %Ecto.Changeset{} = Contacts.change_category(category)
    end
  end
end
