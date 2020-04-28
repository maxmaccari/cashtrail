defmodule Cashtray.Factory.ContactsFactory do
  @moduledoc false

  alias Cashtray.Contacts.Category
  alias Cashtray.Entities.Tenants

  defmacro __using__(_opts) do
    quote do
      def contact_category_factory(%{entity: entity} = attrs) do
        entity =
          %Category{
            description: Faker.App.name()
          }
          |> Ecto.put_meta(prefix: Tenants.to_prefix(entity))

        merge_attributes(entity, Map.drop(attrs, [:entity]))
      end
    end
  end
end
