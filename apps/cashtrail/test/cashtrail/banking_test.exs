defmodule Cashtrail.BankingTest do
  @moduledoc false

  use Cashtrail.TenantCase

  alias Cashtrail.{Banking, Paginator}

  describe "institutions" do
    test "list_institutions/2 returns all institutions", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)
      assert Banking.list_institutions(tenant).entries == [institution]
    end

    test "list_institutions/2 works with pagination", %{tenant: tenant} do
      institutions =
        insert_list(25, :institution, tenant: tenant)
        |> Enum.slice(20, 5)

      assert Banking.list_institutions(tenant, page: 2) == %Paginator.Page{
               entries: institutions,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_institutions/2 searching by iso_code, symbol and description", %{tenant: tenant} do
      insert(:institution,
        tenant: tenant,
        country: "abc",
        contact: build(:contact, name: "def", legal_name: "ijk")
      )

      institution =
        insert(:institution,
          tenant: tenant,
          country: "lmnopq",
          contact: build(:contact, name: "rstuv", legal_name: "wxyz")
        )

      assert Banking.list_institutions(tenant, search: "mno").entries == [institution]
      assert Banking.list_institutions(tenant, search: "rst").entries == [institution]
      assert Banking.list_institutions(tenant, search: "xyz").entries == [institution]
    end

    test "get_institution!/2 returns the institution with given id", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)
      assert Banking.get_institution!(tenant, institution.id) == institution
    end

    test "create_institution/2 with valid data creates a institution", %{tenant: tenant} do
      institution_params =
        params_for(:institution, tenant: tenant)
        |> Map.put(:contact, params_for(:contact))

      assert {:ok, %Banking.Institution{} = institution} =
               Banking.create_institution(tenant, institution_params)

      assert institution.country == institution_params.country
      assert institution.bank_code == institution_params.bank_code
      assert institution.swift == institution_params.swift
      assert institution.logo_url == institution_params.logo_url
      assert institution.contact.name == institution_params.contact.name
    end

    test "create_institution/2 with contact_id creates a institution with existing contact", %{
      tenant: tenant
    } do
      contact = insert(:contact, tenant: tenant)
      institution_params = params_for(:institution, tenant: tenant, contact_id: contact.id)

      assert {:ok, %Banking.Institution{} = institution} =
               Banking.create_institution(tenant, institution_params)

      assert institution.country == institution_params.country
      assert institution.bank_code == institution_params.bank_code
      assert institution.swift == institution_params.swift
      assert institution.logo_url == institution_params.logo_url
      assert institution.contact.id == contact.id
    end

    @invalid_attrs %{logo_url: "invalid url", swift: "invalid swift"}
    test "create_institution/2 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Banking.create_institution(tenant, @invalid_attrs)

      assert %{
               contact: ["can't be blank"],
               logo_url: ["is not a valid url"],
               swift: ["is not a valid swift code"]
             } = errors_on(changeset)
    end

    @update_attrs %{
      country: "Brazil",
      bank_code: "875",
      logo_url: "http://some-url.com/logo.png",
      swift: "JEKPQS9478"
    }
    test "update_institution/2 with valid data updates the institution", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)

      assert {:ok, %Banking.Institution{} = institution} =
               Banking.update_institution(institution, @update_attrs)

      assert institution.country == "Brazil"
      assert institution.bank_code == "875"
      assert institution.logo_url == "http://some-url.com/logo.png"
      assert institution.swift == "JEKPQS9478"
    end

    test "update_institution/2 with invalid data returns error changeset", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)
      assert {:error, %Ecto.Changeset{}} = Banking.update_institution(institution, @invalid_attrs)
      assert institution == Banking.get_institution!(tenant, institution.id)
    end

    test "delete_institution/1 deletes the institution", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)
      assert {:ok, %Banking.Institution{}} = Banking.delete_institution(institution)
      assert_raise Ecto.NoResultsError, fn -> Banking.get_institution!(tenant, institution.id) end
    end

    test "change_institution/1 returns a institution changeset", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)
      assert %Ecto.Changeset{} = Banking.change_institution(institution)
    end
  end

  describe "accounts" do
    test "list_accounts/2 returns all accounts", %{tenant: tenant} do
      %{id: account_id} = insert(:account, tenant: tenant)

      assert %Paginator.Page{entries: [%Banking.Account{id: ^account_id}]} =
               Banking.list_accounts(tenant)
    end

    test "list_accounts/2 works with pagination", %{tenant: tenant} do
      accounts = insert_list(25, :account, tenant: tenant)

      assert %Paginator.Page{
               entries: entries,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             } = Banking.list_accounts(tenant, page: 2)

      assert Enum.map(entries, & &1.id) == accounts |> Enum.slice(20, 5) |> Enum.map(& &1.id)
    end

    test "list_accounts/2 filtering by type", %{tenant: tenant} do
      insert(:account, tenant: tenant, type: :cash)
      %{id: account_id} = insert(:account, tenant: tenant, type: :checking)

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{type: :checking})

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{"type" => "checking"})
    end

    test "list_accounts/2 filtering by status", %{tenant: tenant} do
      insert(:account, tenant: tenant, status: :archived)
      %{id: account_id} = insert(:account, tenant: tenant, status: :active)

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{status: :active})

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{"status" => "active"})
    end

    test "list_accounts/2 filtering by currency", %{tenant: tenant} do
      insert(:account, tenant: tenant)
      %{id: account_id} = insert(:account, tenant: tenant, currency: "BRL")

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{currency: "BRL"})

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{"currency" => "BRL"})

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{currency: ["BRL"]})
    end

    test "list_accounts/2 filtering by institution_id", %{tenant: tenant} do
      insert(:account, tenant: tenant)
      institution = insert(:institution, tenant: tenant)
      %{id: account_id} = insert(:account, tenant: tenant, institution: institution)

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{institution_id: institution.id})

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{"institution_id" => institution.id})

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, filter: %{institution_id: [institution.id]})
    end

    test "list_accounts/2 filtering by invalid filters show all results", %{tenant: tenant} do
      insert(:account, tenant: tenant)

      assert %Paginator.Page{
               entries: [%Banking.Account{}]
             } = Banking.list_accounts(tenant, filter: %{invalid: :invalid})

      assert %Paginator.Page{
               entries: [%Banking.Account{}]
             } = Banking.list_accounts(tenant, filter: %{"invalid" => "invalid"})
    end

    test "list_accounts/2 searching by description", %{tenant: tenant} do
      insert(:account, tenant: tenant, description: "Dummy Description")
      %{id: account_id} = insert(:account, tenant: tenant, description: "Find Me")

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, search: "find")

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, search: "me")

      assert %Paginator.Page{
               entries: [%Banking.Account{id: ^account_id}]
             } = Banking.list_accounts(tenant, search: "find me")

      assert %Paginator.Page{entries: []} = Banking.list_accounts(tenant, search: "nothing")
    end

    test "get_account!/2 returns the account with given id", %{tenant: tenant} do
      %{id: account_id} = insert(:account, tenant: tenant)
      assert %Banking.Account{id: ^account_id} = Banking.get_account!(tenant, account_id)
    end

    test "create_account/2 with valid data creates a account", %{tenant: tenant} do
      account_params = params_for(:account, tenant: tenant)

      assert {:ok, %Banking.Account{} = account} = Banking.create_account(tenant, account_params)
      assert account.status == :active
      assert account.type == account_params.type
      assert account.avatar_url == account_params.avatar_url
      assert account.description == account_params.description
      assert account.currency == account_params.currency
      assert account.initial_balance_amount == account_params.initial_balance_amount
      assert account.initial_balance_date == account_params.initial_balance_date
      assert account.restricted_transaction_types == account_params.restricted_transaction_types

      assert account.identifier.bank_code == account_params.identifier.bank_code
      assert account.identifier.branch == account_params.identifier.branch
      assert account.identifier.number == account_params.identifier.number
      assert account.identifier.swift == account_params.identifier.swift
      assert account.identifier.iban == account_params.identifier.iban
    end

    @invalid_attrs %{
      description: nil,
      identifier: %{"swift" => "invalid", "iban" => "invalid"},
      initial_balance_amount: "abc",
      initial_balance_date: "2019",
      restricted_transaction_types: ["invalid"],
      status: :invalid,
      type: :invalid
    }

    test "create_account/2 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Banking.create_account(tenant, @invalid_attrs)

      assert %{
               description: ["can't be blank"],
               initial_balance_amount: ["is invalid"],
               initial_balance_date: ["is invalid"],
               restricted_transaction_types: ["is invalid"],
               type: ["is invalid"],
               identifier: %{
                 swift: ["is not a valid swift"],
                 iban: ["is not a valid iban"]
               }
             } = errors_on(changeset)
    end

    @update_attrs %{
      avatar_url: "some updated avatar_url",
      description: "some updated description",
      identifier: %{
        bank_code: "000",
        branch: "0000",
        number: "000000",
        swift: "JEKPQS9478",
        iban: "NL49DLNW6040434458"
      },
      initial_balance_amount: "123.4",
      status: "archived"
    }

    test "update_account/2 with valid data updates the account", %{tenant: tenant} do
      account = insert(:account, tenant: tenant)
      assert {:ok, %Banking.Account{} = account} = Banking.update_account(account, @update_attrs)

      assert account.avatar_url == "some updated avatar_url"
      assert account.description == "some updated description"
      assert account.initial_balance_amount == Decimal.new("123.4")
      assert account.status == :archived

      assert %Banking.AccountIdentifier{
               bank_code: "000",
               branch: "0000",
               number: "000000",
               swift: "JEKPQS9478",
               iban: "NL49DLNW6040434458"
             } = account.identifier
    end

    test "update_account/2 with invalid data returns error changeset", %{tenant: tenant} do
      %{
        id: account_id,
        description: account_description,
        status: status,
        identifier: identifier
      } = account = insert(:account, tenant: tenant)

      assert {:error, %Ecto.Changeset{}} = Banking.update_account(account, @invalid_attrs)

      assert %{
               id: ^account_id,
               description: ^account_description,
               status: ^status,
               identifier: ^identifier
             } = Banking.get_account!(tenant, account.id)
    end

    test "delete_account/1 deletes the account", %{tenant: tenant} do
      account = insert(:account, tenant: tenant)
      assert {:ok, %Banking.Account{}} = Banking.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Banking.get_account!(tenant, account.id) end
    end

    test "change_account/1 returns a account changeset", %{tenant: tenant} do
      account = insert(:account, tenant: tenant)
      assert %Ecto.Changeset{} = Banking.change_account(account)
    end
  end
end
