defmodule Cashtray.Entities.Entity do
  @moduledoc """
  It represents a division to which all data belongs to. So you can separate your
  personal finances from the company finances. Or have Personal Finances and
  Family finances separated.

  Each Entity generates a prefix in Ecto.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtray.Accounts.User
  alias Cashtray.Entities.EntityMember

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entities" do
    field :name, :string
    field :status, :string, default: "active"
    field :type, :string, default: "personal"
    belongs_to :owner, User
    has_many :members, EntityMember

    timestamps()
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:name, :type, :status])
    |> validate_required([:name, :type, :status, :owner_id])
    |> validate_inclusion(:type, ["personal", "company", "other"])
    |> validate_inclusion(:status, ["active", "archived"])
    |> foreign_key_constraint(:owner_id)
  end

  @doc false
  def transfer_changeset(entity, attrs) do
    entity
    |> cast(attrs, [:owner_id])
    |> validate_required([:owner_id])
    |> foreign_key_constraint(:owner_id)
  end
end
