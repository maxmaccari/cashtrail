defmodule Cashtrail.Entities.Entity do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents an entity of the application.

  ## Definition
  According to [Techopedia](https://www.techopedia.com/definition/14360/entity-computing),
  an entity is any singular, identifiable, and separate object. It refers to individuals,
  organizations, systems, bits of data, or even distinct system components that are
  considered significant in and of themselves.

  So, in this application, an entity is a division of what the data belongs to. This
  can be an individual, an organization, a department, a church, a group of friends,
  and whatever you want to control the finances.

  So you can separate your finances from the company finances. Or have
  Personal Finances and Family finances separated. Or control the finances of some
  organization by departments.

  Each user can create their entity to control their finances and includes other
  users as a member of the entity. You can see `Cashtrail.Entities.EntityMember`
  to know more about this.

  ## Multitenancy

  Each Entity generates a tenant through new schemas in the Postgres database.
  This happens to separate logically the data of entities. This can help to maintain
  data integrity and security, as this makes it harder to one data from one entity
  flow to another entity, like one account trying to relate a currency from another
  entity, for instance.

  You can manually generate or drop tenants using the `Cashtrail.Entities.Tenants`
  module.

  ## Fields

  * `:id` - The unique id of the entity.
  * `:name` - The name (or description) of the entity.
  * `:type` - The type of the entity, that can be:
    * `:personal` - if the entity is used for personal reasons, like control
    your finances, your family finances, personal project finances,
    or something like that.
    * `:company` - if the entity is used to control the finances of a company.
    * `:other` - if the entity is used to control the finances for other reasons.
    * `:owner` - The owner of the entity. The owner is usually who has created the
    entity and has all permissions over an entity, including to delete it. If a
    user is deleted, all his entities are excluded too. The ownership of an entity
    can be transferred as well.
  * `:owner_id` - The id of the owner of the entity.
  * `:members` - The members of the entity. You can read more about this at
  `Cashtrail.Entities.EntityMember`.
  * `:inserted_at` - When the entity was inserted at the first time.
  * `:updated_at` - When the entity was updated at the last time.
  * `:archived_at` - When the entity was archived.

  See `Cashtrail.Entities` to know how to list, get, insert, update, delete, and
  transfer the ownership of an entity.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtrail.{Entities, Users}

  @type t :: %Cashtrail.Entities.Entity{
          id: Ecto.UUID.t() | nil,
          name: String.t() | nil,
          type: atom() | nil,
          owner_id: Ecto.UUID.t() | nil,
          owner: Ecto.Association.NotLoaded.t() | Users.User.t() | nil,
          members: Ecto.Association.NotLoaded.t() | list(Entities.EntityMember.t()),
          archived_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @derive [Cashtrail.Statuses.WithStatus]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entities" do
    field :name, :string
    field :type, Ecto.Enum, values: [:personal, :company, :other], default: :personal

    belongs_to :owner, Users.User
    has_many :members, Entities.EntityMember

    field :archived_at, :naive_datetime
    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :owner_id])
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

  @spec archive_changeset(t | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def archive_changeset(entity) do
    change(entity, %{archived_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)})
  end

  @spec unarchive_changeset(t | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def unarchive_changeset(entity) do
    change(entity, %{archived_at: nil})
  end
end
