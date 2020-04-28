defmodule Cashtray.Factory.ContactsFactory do
  @moduledoc false

  alias Cashtray.Contacts.{Category, Contact}
  alias Cashtray.Factory.Helpers

  defmacro __using__(_opts) do
    quote do
      def contact_category_factory(attrs \\ %{}) do
        %Category{
          description: sequence(:category, &"Category #{&1}")
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end

      def contact_factory(attrs \\ %{}) do
        %Contact{
          name: Faker.App.name(),
          legal_name: Faker.Company.name(),
          tax_id: Faker.App.name(),
          type: Enum.random(["company", "person"]),
          customer: Enum.random([true, false]),
          supplier: Enum.random([true, false]),
          phone: Faker.Phone.EnUs.phone(),
          email: Faker.Internet.email(),
          address: %Cashtray.Contacts.Address{
            street: Faker.Address.street_name(),
            number: Faker.Address.building_number(),
            line_1: Faker.Address.secondary_address(),
            line_2: Faker.Address.city(),
            city: Faker.Address.city(),
            state: Faker.Address.state(),
            country: Faker.Address.country(),
            zip: Faker.Address.zip(),
            id: Ecto.UUID.generate()
          },
          category: build(:contact_category)
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end
    end
  end
end
