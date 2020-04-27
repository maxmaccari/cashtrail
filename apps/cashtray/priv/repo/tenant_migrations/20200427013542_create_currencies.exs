defmodule Cashtray.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false
      add :iso_code, :string
      add :symbol, :string, null: false, default: ""
      add :format, :string, null: false, default: "#0.00"
      add :type, :string, null: false, default: "cash"
      add :active, :boolean, default: true, null: false

      timestamps()
    end
  end
end
