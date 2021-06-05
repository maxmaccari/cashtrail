defmodule Cashtrail.Factory.BankingFactory do
  @moduledoc false

  alias Cashtrail.Banking
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

        %Banking.Currency{
          active: true,
          description: "#{iso_code} Currency",
          iso_code: iso_code,
          type: Enum.random([:money, :cryptocurrency, :virtual, :other]),
          symbol: "$",
          precision: Enum.random(0..4),
          separator: Enum.random([".", ",", "\\"]),
          delimiter: Enum.random([".", ",", ""]),
          format: "%s%n"
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end

      def institution_factory(attrs \\ %{}) do
        country_code = Faker.Address.country_code()
        bank_code = for(_ <- 1..4, do: [Enum.random(65..90)]) |> to_string()

        region =
          for(_ <- 1..2, do: Enum.random([Enum.random(65..90), Enum.random(48..57)]))
          |> to_string()

        swift = "#{bank_code}#{country_code}#{region}XXX"
        local_code = :rand.uniform(999) |> to_string()

        logo_url =
          "#{Faker.Internet.image_url()}#{Enum.random([".png", ".jpg", ".jpeg", ".gif", ""])}"

        %Banking.Institution{
          country: Faker.Address.country(),
          local_code: local_code,
          swift_code: swift,
          logo_url: logo_url,
          contact: build(:contact)
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end
    end
  end
end
