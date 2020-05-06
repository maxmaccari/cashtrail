defmodule Cashtrail.Entities.Entity do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents an entity of the application.

  **Warning**: Don't use the functions of this module. Only use this module as a
  struct to represent a contact. The functions of this module are internal and
  can change over time. Only manipulate contacts through the `Cashtrail.Entities`
  that is the context for this.

  ## Definition

  According to [AccountingTools](https://www.accountingtools.com/articles/what-is-an-entity.html),
  an entity is something that maintains a separate and distinct existence. In
  business, an entity is an organizational structure that has its own goals,
  processes, and records.

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
  flow to another entity, like one account trying to relate a  currency from another
  entity, for instance.

  In this way, I can maintain the database design inside tenants simpler,
  so I can perform the queries without having to relate two fields, and I can
  ensure the consistency without recurring to things like composite foreign keys.

  The downside is that this methodology doesn't scale well if you want to use this
  application as a "big and scalable SASS application". This happens because if I
  change the database through new migrations, I have to migrate all schemas, and this
  takes time. This is the same for backups.

  As the purpose of this application is not to be scalable, but to be safe and
  flexible, this is not a problem. I recommend you maintain the number of entities
  at a maximum of 100 per instance of this application.

  You can manually generate or drop tenants using the `Cashtrail.Entities.Tenants`
  module.

  ## Fields

  * `:id` - The unique id of the entity.
  * `:name` - The name (or description) of the entity.
  * `:status` - The status of the entity, that can be:
    * `"active"` - if the entity is used;
    * `"archived"` -if the entity is no longer used, but you want to keep the
    data history.
  * `:type` - The type of the entity, that can be:
    * `"personal"` - if the entity is used for personal reasons, like control
    your finances, your family finances, personal project finances,
    or something like that.
    * `"company"` - if the entity is used to control the finances of a company.
    * `"other"` - if the entity is used to control the finances for other reasons.
    * `:owner` - The owner of the entity. The owner is usually who has created the
    entity and has all permissions over an entity, including to delete it. If a
    user is deleted, all his entities are excluded too. The ownership of an entity
    can be transferred as well.
  * `:owner_id` - The id of the owner of the entity.
  * `:members` - The members of the entity. You can read more about this at
  `Cashtrail.Entities.EntityMember`.
  * `:inserted_at` - When the entity was inserted at the first time.
  * `:updated_at` - When the entity was updated at the last time.

  See `Cashtrail.Entities` to know how to list, get, insert, update, delete, and
  transfer the ownership of an entity.
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
