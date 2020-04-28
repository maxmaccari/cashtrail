defmodule Cashtray.ContactsTest do
  @moduledoc false

  use Cashtray.TenantCase

  alias Cashtray.Contacts

  describe "categories" do
    alias Cashtray.Contacts.Category

    test "list_categories/2 returns all categories", %{tenant: tenant} do
      category = insert(:contact_category, tenant: tenant)
      assert Contacts.list_categories(tenant).entries == [category]
    end

    test "list_categories/2 works with pagination", %{tenant: tenant} do
      categories =
        insert_list(25, :contact_category, tenant: tenant)
        |> Enum.slice(20, 5)

      assert Contacts.list_categories(tenant, page: 2) == %Cashtray.Paginator.Page{
               entries: categories,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_categories/2 filtering by searching by description", %{tenant: tenant} do
      insert(:contact_category, tenant: tenant, description: "abc")
      category = insert(:contact_category, tenant: tenant, description: "defghij")
      assert Contacts.list_categories(tenant, search: "fgh").entries == [category]
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

    test "create_category/2 with same name returns error changeset", %{tenant: tenant} do
      category_params = params_for(:contact_category, tenant: tenant)
      assert {:ok, %Category{} = category} = Contacts.create_category(tenant, category_params)
      assert {:error, %Ecto.Changeset{}} = Contacts.create_category(tenant, category_params)
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

  describe "contacts" do
    alias Cashtray.Contacts.Contact

    test "list_contacts/2 returns all contacts", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant) |> forget(:category)
      assert Contacts.list_contacts(tenant).entries == [contact]
    end

    test "list_contacts/2 works with pagination", %{tenant: tenant} do
      categories =
        insert_list(25, :contact, tenant: tenant)
        |> Enum.slice(20, 5)
        |> Enum.map(&forget(&1, :category))

      assert Contacts.list_contacts(tenant, page: 2) == %Cashtray.Paginator.Page{
               entries: categories,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_contacts/2 filtering by type", %{tenant: tenant} do
      insert(:contact, tenant: tenant, type: "person")
      contact = insert(:contact, tenant: tenant, type: "company") |> forget(:category)
      assert Contacts.list_contacts(tenant, filter: %{type: "company"}).entries == [contact]
      assert Contacts.list_contacts(tenant, filter: %{"type" => "company"}).entries == [contact]
    end

    test "list_contacts/2 filtering by customer", %{tenant: tenant} do
      insert(:contact, tenant: tenant, customer: false)
      contact = insert(:contact, tenant: tenant, customer: true) |> forget(:category)
      assert Contacts.list_contacts(tenant, filter: %{customer: true}).entries == [contact]
      assert Contacts.list_contacts(tenant, filter: %{"customer" => true}).entries == [contact]
    end

    test "list_contacts/2 filtering by supplier", %{tenant: tenant} do
      insert(:contact, tenant: tenant, supplier: false)
      contact = insert(:contact, tenant: tenant, supplier: true) |> forget(:category)
      assert Contacts.list_contacts(tenant, filter: %{supplier: true}).entries == [contact]
      assert Contacts.list_contacts(tenant, filter: %{"supplier" => true}).entries == [contact]
    end

    test "list_contacts/2 filtering by invalid key", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant) |> forget(:category)
      assert Contacts.list_contacts(tenant, filter: %{invalid: nil}).entries == [contact]
    end

    test "list_contacts/2 filtering by searching by name", %{tenant: tenant} do
      insert(:contact, tenant: tenant, name: "abc")
      contact = insert(:contact, tenant: tenant, name: "defghij") |> forget(:category)
      assert Contacts.list_contacts(tenant, search: "fgh").entries == [contact]
    end

    test "list_contacts/2 filtering by searching by legal_name", %{tenant: tenant} do
      insert(:contact, tenant: tenant, legal_name: "abc")
      contact = insert(:contact, tenant: tenant, legal_name: "defghij") |> forget(:category)
      assert Contacts.list_contacts(tenant, search: "fgh").entries == [contact]
    end

    test "get_contact!/2 returns the contact with given id", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant) |> forget(:category)
      assert Contacts.get_contact!(tenant, contact.id) == contact
    end

    test "create_contact/2 with valid data creates a contact", %{tenant: tenant} do
      contact_params = params_for(:contact)
      assert {:ok, %Contact{} = contact} = Contacts.create_contact(tenant, contact_params)
      assert contact.customer == contact_params.customer
      assert contact.email == contact_params.email
      assert contact.legal_name == contact_params.legal_name
      assert contact.name == contact_params.name
      assert contact.phone == contact_params.phone
      assert contact.supplier == contact_params.supplier
      assert contact.tax_id == contact_params.tax_id
      assert contact.type == contact_params.type
      assert contact.address.street == contact_params.address.street
      assert contact.address.number == contact_params.address.number
      assert contact.address.line_1 == contact_params.address.line_1
      assert contact.address.line_2 == contact_params.address.line_2
      assert contact.address.city == contact_params.address.city
      assert contact.address.state == contact_params.address.state
      assert contact.address.country == contact_params.address.country
      assert contact.address.zip == contact_params.address.zip
    end

    @invalid_attrs %{
      address: nil,
      customer: nil,
      email: nil,
      legal_name: nil,
      name: nil,
      phone: nil,
      supplier: nil,
      tax_id: nil,
      type: nil
    }
    test "create_contact/2 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(tenant, @invalid_attrs)
    end

    @update_attrs %{
      address: %{street: "My New Street", city: "My New City"},
      customer: false,
      email: "some updated email",
      legal_name: "some updated legal_name",
      name: "some updated name",
      phone: "some updated phone",
      supplier: false,
      tax_id: "some updated tax_id",
      type: "some updated type"
    }
    test "update_contact/2 with valid data updates the contact", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant)
      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, @update_attrs)
      assert contact.address == %{contact.address | street: "My New Street", city: "My New City"}
      assert contact.customer == false
      assert contact.email == "some updated email"
      assert contact.legal_name == "some updated legal_name"
      assert contact.name == "some updated name"
      assert contact.phone == "some updated phone"
      assert contact.supplier == false
      assert contact.tax_id == "some updated tax_id"
      assert contact.type == "some updated type"
    end

    test "update_contact/2 with invalid data returns error changeset", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant) |> forget(:category)
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(tenant, contact.id)
    end

    test "delete_contact/1 deletes the contact", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant)
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(tenant, contact.id) end
    end

    test "change_contact/1 returns a contact changeset", %{tenant: tenant} do
      contact = insert(:contact, tenant: tenant)
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end
end
