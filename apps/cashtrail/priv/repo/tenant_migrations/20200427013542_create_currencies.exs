defmodule Cashtrail.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false
      add :iso_code, :string, size: 3
      add :type, :string, null: false, default: "money"
      add :active, :boolean, null: false, default: true
      add :symbol, :string, null: false, default: ""
      add :precision, :smallint, null: false, default: 0
      add :separator, :string, null: false, default: ","
      add :delimiter, :string, null: false, default: ""
      add :format, :string, null: false, default: "%s%n"

      timestamps()
    end

    create unique_index(:currencies, :iso_code)
    create constraint(:currencies, :currencies_precision_positive_check, check: "precision >= 0")
  end
end
