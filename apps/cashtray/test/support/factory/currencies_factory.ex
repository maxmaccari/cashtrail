defmodule Cashtray.Factory.CurrenciesFactory do
  @moduledoc false

  alias Cashtray.Currencies.Currency
  alias Cashtray.Factory.Helpers

  defmacro __using__(_opts) do
    quote do
      def currency_factory(attrs \\ %{}) do
        %Currency{
          active: true,
          description: "My Coin",
          type: Enum.random(["cash", "digital_currency", "miles", "cryptocurrency", "other"]),
          format: "#0.000,00",
          iso_code: "ABC",
          symbol: "AB$",
          precision: Enum.random(0..6)
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end
    end
  end
end
