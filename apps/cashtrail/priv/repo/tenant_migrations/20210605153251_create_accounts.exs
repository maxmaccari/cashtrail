defmodule Cashtrail.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :string, null: false
      add :currency, :string
      add :type, :string, null: false, default: "cash"
      add :initial_balance_amount, :decimal, null: false, default: 0
      add :initial_balance_date, :date, null: false, default: "now()"
      add :restricted_transaction_types, {:array, :string}
      add :avatar_url, :string
      add :identifier, :map
      add :institution_id, references(:institutions, on_delete: :nothing, type: :binary_id)
      add :predicted_account_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :archived_at, :naive_datetime

      timestamps()
    end

    create index(:accounts, [:currency])
    create index(:accounts, [:type])
    create index(:accounts, [:institution_id])
    create index(:accounts, [:predicted_account_id])
    create index(:accounts, [:archived_at])
  end
end
