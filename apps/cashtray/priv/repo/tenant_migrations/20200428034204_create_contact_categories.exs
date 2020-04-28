defmodule Cashtray.Repo.Migrations.CreateContactCategories do
  use Ecto.Migration

  def change do
    create table(:contact_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false

      timestamps()
    end

    create unique_index(:contact_categories, :description)
  end
end
