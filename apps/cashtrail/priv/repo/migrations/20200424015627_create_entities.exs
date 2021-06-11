defmodule Cashtrail.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    create table(:entities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false, default: "personal"

      add :owner_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :archived_at, :naive_datetime
      timestamps()
    end

    create index(:entities, [:owner_id])
    create index(:entities, [:archived_at])
  end
end
