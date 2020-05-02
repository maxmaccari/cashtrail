defmodule Cashtrail.Entities.Entity do
  @moduledoc """
  It represents a division to which all data belongs to. So you can separate your
  personal finances from the company finances. Or have Personal Finances and
  Family finances separated. Or control finances of some organization.

  Each Entity generates a tenant. You can manually generate tenats using the
  `Cashtrail.Entities.Tenants` module.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.Users.User
  alias Cashtrail.Entities.EntityMember

  @type t() :: %Cashtrail.Entities.Entity{
          id: Ecto.UUID.t() | nil,
          name: String.t() | nil,
          status: String.t() | nil,
          type: String.t() | nil,
          owner_id: Ecto.UUID.t() | nil,
          owner: Ecto.Association.NotLoaded.t() | User.t() | nil,
          members: Ecto.Association.NotLoaded.t() | list(EntityMember.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

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
  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:name, :type, :status])
    |> validate_required([:name, :owner_id])
    |> validate_inclusion(:type, ["personal", "company", "other"])
    |> validate_inclusion(:status, ["active", "archived"])
    |> foreign_key_constraint(:owner_id)
  end

  @doc false
  @spec transfer_changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  def transfer_changeset(entity, attrs) do
    entity
    |> cast(attrs, [:owner_id])
    |> validate_required([:owner_id])
    |> foreign_key_constraint(:owner_id)
  end
end
