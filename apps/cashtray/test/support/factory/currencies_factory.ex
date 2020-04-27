defmodule Cashtray.Factory.CurrenciesFactory do
  @moduledoc false

  alias Cashtray.Currencies.Currency
  alias Cashtray.Entities.Tenants

  defmacro __using__(_opts) do
    quote do
      def currency_factory(%{entity: entity} = attrs) do
        entity =
          %Currency{
            active: true,
            description: "My Coin",
            type: Enum.random(["cash", "digital_currency", "miles", "cryptocurrency", "other"]),
            format: "#0.000,00",
            iso_code: "ABC",
            symbol: "AB$"
          }
          |> Ecto.put_meta(prefix: Tenants.to_prefix(entity))

        merge_attributes(entity, Map.drop(attrs, [:entity]))
      end
    end
  end
end
