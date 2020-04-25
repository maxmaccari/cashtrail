defmodule Cashtray.Repo.Migrations.CreateEntityMembers do
  use Ecto.Migration

  def change do
    create table(:entity_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_id, references(:entities, on_delete: :nothing, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :permission, :string, null: false, default: "read"

      timestamps()
    end

    create index(:entity_members, [:entity_id])
    create index(:entity_members, [:user_id])
    create unique_index(:entity_members, [:entity_id, :user_id])
  end
end
