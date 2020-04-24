defmodule Cashtray.Entities.Entity do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtray.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entities" do
    field(:name, :string)
    field(:status, :string, default: "active")
    field(:type, :string, default: "personal")
    belongs_to(:owner, User)

    timestamps()
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:name, :type, :status, :owner_id])
    |> validate_required([:name, :type, :status, :owner_id])
    |> validate_inclusion(:type, ["personal", "company", "other"])
    |> validate_inclusion(:status, ["active", "archived"])
  end
end
