defmodule Cashtrail.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false
      add :type, :string, default: "cash"
      add :status, :string, default: "active"
      add :initial_balance_amount, :decimal, default: 0
      add :initial_balance_date, :date, default: "now()"
      add :restricted_transaction_types, {:array, :string}
      add :avatar_url, :string
      add :identifier, :map
      add :currency_id, references(:currencies, on_delete: :nothing, type: :binary_id)
      add :institution_id, references(:institutions, on_delete: :nothing, type: :binary_id)
      add :predicted_account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:accounts, [:currency_id])
    create index(:accounts, [:institution_id])
    create index(:accounts, [:predicted_account_id])
  end
end
