defmodule Cashtray.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :legal_name, :string
      add :tax_id, :string
      add :type, :string, null: false, default: "company"
      add :customer, :boolean, default: false, null: false
      add :supplier, :boolean, default: false, null: false
      add :phone, :string
      add :email, :string
      add :address, :map, default: %{}
      add :category_id, references(:contact_categories, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contacts, [:category_id])
  end
end
