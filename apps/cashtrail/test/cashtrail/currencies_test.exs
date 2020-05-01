defmodule Cashtrail.CurrenciesTest do
  @moduledoc false

  use Cashtrail.TenantCase

  alias Cashtrail.Currencies

  describe "currencies" do
    alias Cashtrail.Currencies.Currency

    test "list_currencies/1 returns all currencies", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert Currencies.list_currencies(tenant).entries == [currency]
    end

    test "list_currencies/1 works with pagination", %{tenant: tenant} do
      currencies =
        insert_list(25, :currency, tenant: tenant)
        |> Enum.slice(20, 5)

      assert Currencies.list_currencies(tenant, page: 2) == %Cashtrail.Paginator.Page{
               entries: currencies,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_currencies/1 filtering by type", %{tenant: tenant} do
      insert(:currency, tenant: tenant, type: "digital_currency")
      currency = insert(:currency, tenant: tenant, type: "cash")

      assert Currencies.list_currencies(tenant, filter: %{type: "cash"}).entries == [currency]
      assert Currencies.list_currencies(tenant, filter: %{"type" => "cash"}).entries == [currency]
    end

    test "list_currencies/1 filtering by active", %{tenant: tenant} do
      insert(:currency, tenant: tenant, active: false)
      currency = insert(:currency, tenant: tenant, active: true)

      assert Currencies.list_currencies(tenant, filter: %{active: true}).entries == [currency]
      assert Currencies.list_currencies(tenant, filter: %{"active" => true}).entries == [currency]
    end

    test "list_currencies/1 filtering by invalid filters show all results", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)

      assert Currencies.list_currencies(tenant, filter: %{invalid: "123"}).entries == [currency]
    end

    test "list_currencies/1 searching by iso_code, symbol and description", %{tenant: tenant} do
      insert(:currency, tenant: tenant, description: "abc", iso_code: "cde", symbol: "ef$")

      currency =
        insert(:currency, tenant: tenant, description: "ghijk", iso_code: "lmn", symbol: "op$")

      assert Currencies.list_currencies(tenant, search: "hij").entries == [currency]
      assert Currencies.list_currencies(tenant, search: "lm").entries == [currency]
      assert Currencies.list_currencies(tenant, search: "p$").entries == [currency]
    end

    test "get_currency!/2 returns the currency with given id", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert Currencies.get_currency!(tenant, currency.id) == currency
    end

    test "create_currency/2 with valid data creates a currency", %{tenant: tenant} do
      currency_params = params_for(:currency, tenant: tenant)
      assert {:ok, %Currency{} = currency} = Currencies.create_currency(tenant, currency_params)
      assert currency.active == true
      assert currency.description == currency_params.description
      assert currency.format == currency_params.format
      assert currency.iso_code == currency_params.iso_code
      assert currency.symbol == currency_params.symbol
      assert currency.type == currency_params.type
      assert currency.precision == currency_params.precision
    end

    test "create_currency/2 with downcased iso_code upcases the value", %{tenant: tenant} do
      currency_params = params_for(:currency, tenant: tenant, iso_code: "abc")
      assert {:ok, %Currency{} = currency} = Currencies.create_currency(tenant, currency_params)
      assert currency.iso_code == "ABC"
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
      assert {:error, %Ecto.Changeset{}} = Currencies.create_currency(tenant, @invalid_attrs)
    end

    test "create_currency/2 with invalid type returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  type: {"is invalid", _}
                ]
              }} = Currencies.create_currency(tenant, params_for(:currency, type: "invalid"))
    end

    test "create_currency/2 with invalid precission returns error changeset", %{tenant: tenant} do
      assert {:error,
              %Ecto.Changeset{
                errors: [
                  precision:
                    {"must be greater than or equal to %{number}",
                     [validation: :number, kind: :greater_than_or_equal_to, number: 0]}
                ]
              }} = Currencies.create_currency(tenant, params_for(:currency, precision: -1))
    end

    test "create_currency/2 with invalid iso_code returns error changeset", %{tenant: tenant} do
      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"is not a valid ISO 4217 code", _},
           iso_code: {"should be %{count} character(s)", _}
         ]
       }} = Currencies.create_currency(tenant, params_for(:currency, iso_code: "ab"))

      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"should be %{count} character(s)", _}
         ]
       }} = Currencies.create_currency(tenant, params_for(:currency, iso_code: "abcd"))

      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"is not a valid ISO 4217 code", _}
         ]
       }} = Currencies.create_currency(tenant, params_for(:currency, iso_code: "a b"))

      {:error,
       %Ecto.Changeset{
         errors: [
           iso_code: {"is not a valid ISO 4217 code", _}
         ]
       }} = Currencies.create_currency(tenant, params_for(:currency, iso_code: "a1b"))
    end

    test "create_currency/2 with same iso_code returns a error changeset", %{tenant: tenant} do
      currency_params = params_for(:currency, tenant: tenant, iso_code: "ABC")
      assert {:ok, %Currency{} = currency} = Currencies.create_currency(tenant, currency_params)

      assert {:error, %Ecto.Changeset{errors: [iso_code: _]}} =
               Currencies.create_currency(tenant, currency_params)
    end

    @update_attrs %{
      active: false,
      description: "some updated description",
      format: "some updated format",
      iso_code: "ABC",
      symbol: "some updated symbol",
      type: "digital_currency",
      precision: "3"
    }
    test "update_currency/2 with valid data updates the currency", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert {:ok, %Currency{} = currency} = Currencies.update_currency(currency, @update_attrs)
      assert currency.active == false
      assert currency.description == "some updated description"
      assert currency.format == "some updated format"
      assert currency.iso_code == "ABC"
      assert currency.symbol == "some updated symbol"
      assert currency.type == "digital_currency"
      assert currency.precision == 3
    end

    test "update_currency/2 with invalid data returns error changeset", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert {:error, %Ecto.Changeset{}} = Currencies.update_currency(currency, @invalid_attrs)
      assert currency == Currencies.get_currency!(tenant, currency.id)
    end

    test "delete_currency/1 deletes the currency", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert {:ok, %Currency{}} = Currencies.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Currencies.get_currency!(tenant, currency.id) end
    end

    test "change_currency/1 returns a currency changeset", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert %Ecto.Changeset{} = Currencies.change_currency(currency)
    end
  end
end
