defmodule Cashtrail.EntitiesWithTenantsTest do
  @moduledoc false

  use Cashtrail.DataCase

  describe "entity with tenants" do
    alias Cashtrail.{Entities, Users}

    setup do
      Ecto.Adapters.SQL.Sandbox.mode(Cashtrail.Repo, :auto)

      on_exit(fn ->
        Ecto.Adapters.SQL.Sandbox.mode(Cashtrail.Repo, :manual)
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
          from(Users.User, where: [id: ^owner_id])
          |> Repo.delete_all()
        end
      end)
    end

    test "create_entity/3 with valid data creates a tenant with the entity id" do
      user = insert(:user)

      assert {:ok, %Entities.Entity{} = entity} =
               Entities.create_entity(user, params_for(:entity))

      assert Triplex.exists?(entity.id)

      cleanup_entity_tenants(entity)
    end

    test "delete_entity/3 deletes the entity tenant" do
      user = insert(:user)
      {:ok, entity} = Entities.create_entity(user, params_for(:entity))

      assert {:ok, %Entities.Entity{}} = Entities.delete_entity(entity)
      refute Triplex.exists?(entity.id)

      cleanup_entity_tenants(nil, entity.owner_id)
    end
  end
end
