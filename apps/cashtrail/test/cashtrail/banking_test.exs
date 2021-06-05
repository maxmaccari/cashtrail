defmodule Cashtrail.BankingTest do
  @moduledoc false

  use Cashtrail.TenantCase

  alias Cashtrail.{Banking, Paginator}

  describe "currencies" do
    test "list_currencies/2 returns all currencies", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert Banking.list_currencies(tenant).entries == [currency]
    end

    test "list_currencies/2 works with pagination", %{tenant: tenant} do
      currencies =
        insert_list(25, :currency, tenant: tenant)
        |> Enum.slice(20, 5)

      assert Banking.list_currencies(tenant, page: 2) == %Paginator.Page{
               entries: currencies,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_currencies/2 filtering by type", %{tenant: tenant} do
      insert(:currency, tenant: tenant, type: :virtual)
      currency = insert(:currency, tenant: tenant, type: :money)

      assert Banking.list_currencies(tenant, filter: %{type: :money}).entries == [currency]

      assert Banking.list_currencies(tenant, filter: %{"type" => "money"}).entries == [
               currency
             ]
    end

    test "list_currencies/2 filtering by active", %{tenant: tenant} do
      insert(:currency, tenant: tenant, active: false)
      currency = insert(:currency, tenant: tenant, active: true)

      assert Banking.list_currencies(tenant, filter: %{active: true}).entries == [currency]
      assert Banking.list_currencies(tenant, filter: %{"active" => true}).entries == [currency]
    end

    test "list_currencies/2 filtering by invalid filters show all results", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)

      assert Banking.list_currencies(tenant, filter: %{invalid: "123"}).entries == [currency]
    end

    test "list_currencies/2 searching by iso_code, symbol and description", %{tenant: tenant} do
      insert(:currency, tenant: tenant, description: "abc", iso_code: "cde", symbol: "ef$")

      currency =
        insert(:currency, tenant: tenant, description: "ghijk", iso_code: "lmn", symbol: "op$")

      assert Banking.list_currencies(tenant, search: "hij").entries == [currency]
      assert Banking.list_currencies(tenant, search: "lm").entries == [currency]
      assert Banking.list_currencies(tenant, search: "p$").entries == [currency]
    end

    test "get_currency!/2 returns the currency with given id", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert Banking.get_currency!(tenant, currency.id) == currency
    end

    test "create_currency/2 with valid data creates a currency", %{tenant: tenant} do
      currency_params = params_for(:currency, tenant: tenant)

      assert {:ok, %Banking.Currency{} = currency} =
               Banking.create_currency(tenant, currency_params)

      assert currency.active == true
      assert currency.description == currency_params.description
      assert currency.format == currency_params.format
      assert currency.iso_code == currency_params.iso_code
      assert currency.symbol == currency_params.symbol
      assert currency.type == currency_params.type
      assert currency.precision == currency_params.precision
      assert currency.separator == currency_params.separator
      assert currency.delimiter == currency_params.delimiter
    end

    test "create_currency/2 with downcased iso_code upcases the value", %{tenant: tenant} do
      currency_params = params_for(:currency, tenant: tenant, iso_code: "abc")

      assert {:ok, %Banking.Currency{} = currency} =
               Banking.create_currency(tenant, currency_params)

      assert currency.iso_code == "ABC"
    end

    test "create_currency/2 with allowed empty values sets defaults values", %{tenant: tenant} do
      currency_params =
        params_for(:currency, tenant: tenant, separator: "", format: "", type: "", active: nil)

      assert {:ok, %Banking.Currency{} = currency} =
               Banking.create_currency(tenant, currency_params)

      assert currency.type == :money
      assert currency.active == true
      assert currency.separator == "."
      assert currency.format == "%s%n"
    end

    @invalid_attrs %{
      active: nil,
      description: nil,
      format: nil,
      iso_code: nil,
      symbol: nil,
      type: "abcd",
      precision: -1
    }
    test "create_currency/2 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{}} = Banking.create_currency(tenant, @invalid_attrs)
    end

    test "create_currency/2 with invalid type returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  type: {"is invalid", _}
                ]
              }} = Banking.create_currency(tenant, params_for(:currency, type: "invalid"))
    end

    test "create_currency/2 with invalid precission returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  precision:
                    {"must be greater than or equal to %{number}",
                     [validation: :number, kind: :greater_than_or_equal_to, number: 0]}
                ]
              }} = Banking.create_currency(tenant, params_for(:currency, precision: -1))
    end

    test "create_currency/2 with invalid iso_code returns error changeset", %{tenant: tenant} do
      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"is not a valid ISO 4217 code", _},
           iso_code: {"should be %{count} character(s)", _}
         ]
       }} = Banking.create_currency(tenant, params_for(:currency, iso_code: "ab"))

      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"should be %{count} character(s)", _}
         ]
       }} = Banking.create_currency(tenant, params_for(:currency, iso_code: "abcd"))

      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"is not a valid ISO 4217 code", _}
         ]
       }} = Banking.create_currency(tenant, params_for(:currency, iso_code: "a b"))

      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"is not a valid ISO 4217 code", _}
         ]
       }} = Banking.create_currency(tenant, params_for(:currency, iso_code: "a1b"))
    end

    test "create_currency/2 with same iso_code returns a error changeset", %{tenant: tenant} do
      currency_params = params_for(:currency, tenant: tenant, iso_code: "ABC")

      assert {:ok, %Banking.Currency{}} = Banking.create_currency(tenant, currency_params)

      assert {:error, %Ecto.Changeset{errors: [iso_code: _]}} =
               Banking.create_currency(tenant, currency_params)
    end

    test "create_currency/2 with invalid separator returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  separator:
                    {"should be %{count} character(s)",
                     [count: 1, validation: :length, kind: :is, type: :string]}
                ]
              }} = Banking.create_currency(tenant, params_for(:currency, separator: ".."))
    end

    test "create_currency/2 with invalid delimiter returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  delimiter:
                    {"should be at most %{count} character(s)",
                     [count: 1, validation: :length, kind: :max, type: :string]}
                ]
              }} = Banking.create_currency(tenant, params_for(:currency, delimiter: ".."))
    end

    test "create_currency/2 with invalid format returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  format: {"Should have one %n to display the number, or be empty", []}
                ]
              }} = Banking.create_currency(tenant, params_for(:currency, format: "%s"))
    end

    @update_attrs %{
      active: false,
      description: "some updated description",
      format: "%n",
      iso_code: "ABC",
      symbol: "M$",
      type: "virtual",
      precision: "3",
      separator: ",",
      delimiter: "."
    }
    test "update_currency/2 with valid data updates the currency", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)

      assert {:ok, %Banking.Currency{} = currency} =
               Banking.update_currency(currency, @update_attrs)

      assert currency.active == false
      assert currency.description == "some updated description"
      assert currency.format == "%n"
      assert currency.iso_code == "ABC"
      assert currency.symbol == "M$"
      assert currency.type == :virtual
      assert currency.precision == 3
      assert currency.separator == ","
      assert currency.delimiter == "."
    end

    test "update_currency/2 with invalid data returns error changeset", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert {:error, %Ecto.Changeset{}} = Banking.update_currency(currency, @invalid_attrs)
      assert currency == Banking.get_currency!(tenant, currency.id)
    end

    test "delete_currency/1 deletes the currency", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert {:ok, %Banking.Currency{}} = Banking.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Banking.get_currency!(tenant, currency.id) end
    end

    test "change_currency/1 returns a currency changeset", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert %Ecto.Changeset{} = Banking.change_currency(currency)
    end
  end

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
      assert institution.local_code == institution_params.local_code
      assert institution.swift_code == institution_params.swift_code
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
      assert institution.local_code == institution_params.local_code
      assert institution.swift_code == institution_params.swift_code
      assert institution.logo_url == institution_params.logo_url
      assert institution.contact.id == contact.id
    end

    @invalid_attrs %{logo_url: "invalid url", swift_code: "invalid swift"}
    test "create_institution/2 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{}} = Banking.create_institution(tenant, @invalid_attrs)
    end

    @update_attrs %{
      country: "Brazil",
      local_code: "875",
      logo_url: "http://some-url.com/logo.png",
      swift_code: "JEKPQS9478"
    }
    test "update_institution/2 with valid data updates the institution", %{tenant: tenant} do
      institution = insert(:institution, tenant: tenant)

      assert {:ok, %Banking.Institution{} = institution} =
               Banking.update_institution(institution, @update_attrs)

      assert institution.country == "Brazil"
      assert institution.local_code == "875"
      assert institution.logo_url == "http://some-url.com/logo.png"
      assert institution.swift_code == "JEKPQS9478"
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
end
