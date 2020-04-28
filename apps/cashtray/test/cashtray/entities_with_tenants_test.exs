defmodule Cashtray.EntitiesWithTenantsTest do
  use Cashtray.DataCase

  describe "entity with tenants" do
    alias Cashtray.Entities
    alias Cashtray.Entities.Entity

    def allow_create_entity_tenants() do
      Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)
    end

    def cleanup_entity_tenants(entity, owner_id \\ nil) do
      on_exit(fn ->
        if entity do
          Entities.delete_entity(entity)
        end

        owner_id = (entity && entity.owner_id) || owner_id

        if owner_id do
          from(Cashtray.Accounts.User, where: [id: ^owner_id])
          |> Repo.delete_all()
        end
      end)
    end

    test "create_entity/3 with valid data creates a tenant with the entity id" do
      allow_create_entity_tenants()

      user = insert(:user)

      assert {:ok, %Entity{} = entity} = Entities.create_entity(user, params_for(:entity))
      cleanup_entity_tenants(entity)

      assert Triplex.exists?(entity.id)
    end

    test "delete_entity/3 deletes the entity tenant" do
      allow_create_entity_tenants()
      {:ok, entity} = insert(:user) |> Entities.create_entity(params_for(:entity))
      assert {:ok, %Entity{}} = Entities.delete_entity(entity)
      refute Triplex.exists?(entity.id)
      cleanup_entity_tenants(nil, entity.owner_id)
    end
  end
end
