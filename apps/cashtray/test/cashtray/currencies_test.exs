defmodule Cashtray.CurrenciesTest do
  use Cashtray.DataCase

  alias Cashtray.Currencies

  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Cashtray.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

    owner = insert(:user)
    {:ok, entity} = Cashtray.Entities.create_entity(owner, params_for(:entity))

    on_exit(fn ->
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Cashtray.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

      Cashtray.Entities.delete_entity(entity)
    end)

    {:ok, %{entity: %{entity | owner: owner}}}
  end

  describe "currencies" do
    alias Cashtray.Currencies.Currency

    test "list_currencies/1 returns all currencies", %{entity: entity} do
      currency = insert(:currency, entity: entity)
      assert Currencies.list_currencies(entity) == [currency]
    end

    test "get_currency!/2 returns the currency with given id", %{entity: entity} do
      currency = insert(:currency, entity: entity)
      assert Currencies.get_currency!(entity, currency.id) == currency
    end

    test "create_currency/2 with valid data creates a currency", %{entity: entity} do
      currency_params = params_for(:currency, entity: entity)
      assert {:ok, %Currency{} = currency} = Currencies.create_currency(entity, currency_params)
      assert currency.active == true
      assert currency.description == currency_params.description
      assert currency.format == currency_params.format
      assert currency.iso_code == currency_params.iso_code
      assert currency.symbol == currency_params.symbol
      assert currency.type == currency_params.type
    end

    @invalid_attrs %{
      active: nil,
      description: nil,
      format: nil,
      iso_code: nil,
      symbol: nil,
      type: nil
    }
    test "create_currency/2 with invalid data returns error changeset", %{entity: entity} do
      assert {:error, %Ecto.Changeset{}} = Currencies.create_currency(entity, @invalid_attrs)
    end

    @update_attrs %{
      active: false,
      description: "some updated description",
      format: "some updated format",
      iso_code: "some updated iso_code",
      symbol: "some updated symbol",
      type: "digital_currency"
    }
    test "update_currency/2 with valid data updates the currency", %{entity: entity} do
      currency = insert(:currency, entity: entity)
      assert {:ok, %Currency{} = currency} = Currencies.update_currency(currency, @update_attrs)
      assert currency.active == false
      assert currency.description == "some updated description"
      assert currency.format == "some updated format"
      assert currency.iso_code == "some updated iso_code"
      assert currency.symbol == "some updated symbol"
      assert currency.type == "digital_currency"
    end

    test "update_currency/2 with invalid data returns error changeset", %{entity: entity} do
      currency = insert(:currency, entity: entity)
      assert {:error, %Ecto.Changeset{}} = Currencies.update_currency(currency, @invalid_attrs)
      assert currency == Currencies.get_currency!(entity, currency.id)
    end

    test "delete_currency/1 deletes the currency", %{entity: entity} do
      currency = insert(:currency, entity: entity)
      assert {:ok, %Currency{}} = Currencies.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Currencies.get_currency!(entity, currency.id) end
    end

    test "change_currency/1 returns a currency changeset", %{entity: entity} do
      currency = insert(:currency, entity: entity)
      assert %Ecto.Changeset{} = Currencies.change_currency(currency)
    end
  end
end
