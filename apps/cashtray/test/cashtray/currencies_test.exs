defmodule Cashtray.CurrenciesTest do
  @moduledoc false

  use Cashtray.TenantCase

  alias Cashtray.Currencies

  describe "currencies" do
    alias Cashtray.Currencies.Currency

    test "list_currencies/1 returns all currencies", %{tenant: tenant} do
      currency = insert(:currency, tenant: tenant)
      assert Currencies.list_currencies(tenant).entries == [currency]
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

    @update_attrs %{
      active: false,
      description: "some updated description",
      format: "some updated format",
      iso_code: "some updated iso_code",
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
      assert currency.iso_code == "some updated iso_code"
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
