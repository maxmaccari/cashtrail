defmodule Cashtrail.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION citext", "DROP EXTENSION citext"

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false, default: ""
      add :email, :citext, null: false
      add :password_hash, :string, null: false
      add :avatar_url, :string

      timestamps()
    end

    create unique_index(:users, :email)
  end
end
