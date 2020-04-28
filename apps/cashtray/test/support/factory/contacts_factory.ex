defmodule Cashtray.Factory.ContactsFactory do
  @moduledoc false

  alias Cashtray.Contacts.Category
  alias Cashtray.Factory.Helpers

  defmacro __using__(_opts) do
    quote do
      def contact_category_factory(attrs \\ %{}) do
        %Category{
          description: Faker.App.name()
        }
        |> Helpers.put_tenant(attrs)
        |> merge_attributes(Helpers.drop_tenant(attrs))
      end
    end
  end
end
