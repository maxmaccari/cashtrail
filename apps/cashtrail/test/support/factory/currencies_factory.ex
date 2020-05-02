defmodule Cashtrail.Factory.CurrenciesFactory do
  @moduledoc false

  alias Cashtrail.Banking.Currencies.Currency
  alias Cashtrail.Factory.Helpers

  defmacro __using__(_opts) do
    # Generate a sequence pair from A to Z as first letter, and Z to A as second
    # letter in compile time
    sequence = for(a <- 65..90, b <- 90..65, do: [a, b] |> to_string)

    quote do
      # unquote the generated sequence
      @iso_code_sequence unquote(sequence)

      def currency_factory(attrs \\ %{}) do
        # The first letter is randomily generated
        iso_code_1 = [Enum.random(65..90)] |> to_string()
        # The second and third letter are a sequence from A to Z and Z to A.
        iso_code_2_3 = sequence(:iso_code_2, @iso_code_sequence)
        iso_code = iso_code_1 <> iso_code_2_3

        %Currency{
          active: true,
          description: "My Coin",
          type: Enum.random(["cash", "digital_currency", "miles", "cryptocurrency", "other"]),
          format: "#0.000,00",
          iso_code: iso_code,
          symbol: "$",
          precision: Enum.random(0..6)
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end
    end
  end
end
