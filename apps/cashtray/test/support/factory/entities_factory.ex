defmodule Cashtray.Factory.EntitiesFactory do
  @moduledoc false

  alias Cashtray.Entities.{Entity, EntityMember}

  defmacro __using__(_opts) do
    quote do
      def entity_factory(attrs \\ %{}) do
        entity = %Entity{
          name: "personal finances",
          status: "active",
          type: Enum.random(["personal", "company", "other"]),
          owner: unless(Map.has_key?(attrs, :entity_id), do: build(:user), else: nil)
        }

        merge_attributes(entity, attrs)
      end

      def entity_member_factory(attrs \\ %{}) do
        entity_member = %EntityMember{
          permission: Enum.random(["read", "write", "admin"]),
          entity: unless(Map.has_key?(attrs, :entity_id), do: build(:entity), else: nil),
          user: unless(Map.has_key?(attrs, :user_id), do: build(:user), else: nil)
        }

        merge_attributes(entity_member, attrs)
      end
    end
  end
end
