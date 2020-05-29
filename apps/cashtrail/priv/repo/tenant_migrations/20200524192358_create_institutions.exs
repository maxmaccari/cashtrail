defmodule Cashtrail.Repo.Migrations.CreateInstitutions do
  use Ecto.Migration

  def change do
    create table(:institutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :country, :string
      add :local_code, :string
      add :swift_code, :string
      add :logo_url, :string
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:institutions, [:contact_id])
  end
end
