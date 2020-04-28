defmodule Cashtray.EntitiesWithTenantsTest do
  @moduledoc false

  use Cashtray.DataCase

  describe "entity with tenants" do
    alias Cashtray.Entities
    alias Cashtray.Entities.Entity

    setup do
      Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :auto)

      on_exit(fn ->
        Ecto.Adapters.SQL.Sandbox.mode(Cashtray.Repo, :manual)
      end)

      :ok
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
      user = insert(:user)
      assert {:ok, %Entity{} = entity} = Entities.create_entity(user, params_for(:entity))

      assert Triplex.exists?(entity.id)

      cleanup_entity_tenants(entity)
    end

    test "delete_entity/3 deletes the entity tenant" do
      user = insert(:user)
      {:ok, entity} = Entities.create_entity(user, params_for(:entity))

      assert {:ok, %Entity{}} = Entities.delete_entity(entity)
      refute Triplex.exists?(entity.id)

      cleanup_entity_tenants(nil, entity.owner_id)
    end
  end
end
