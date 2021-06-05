defmodule Cashtrail.Entities do
  @moduledoc """
  The Entities context manages the data related to entities. An Entity keeps all
  financial data of something, that can be a company, financial finances,
  organization, church, event, etc. And they can have one owner or other members,
  as well.

  See `Cashtrail.Entities.Entity` to have more info about entity.
  """

  @type user :: Cashtrail.Users.User.t()
  @type entity :: Cashtrail.Entities.Entity.t()
  @type entity_member :: Cashtrail.Entities.EntityMember.t()
  @type entity_member_permission :: Cashtrail.Entities.EntityMember.permission()

  import Ecto.Query, warn: false
  alias Cashtrail.Repo

  alias Cashtrail.{Entities, Paginator, Users}

  import Cashtrail.QueryBuilder, only: [build_filter: 3, build_search: 3]

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of entities in the
  `:entries` field.

  ## Expected arguments

  * options - A `keyword` list of the following options:
    * `:filter` => filters by following attributes:
      * `:type` or `"type"`
      * `:status` or `"status"`
    * `:search` => search entities by `:name`.
    * See `Cashtrail.Paginator.paginate/2` to see paginations options.

  See `Cashtrail.Entities.Entity` to have more detailed info about the fields to
  be filtered or searched.

  ## Examples

      iex> list_entities()
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.Entity{}, ...]}

      iex> list_entities(filter: %{type: :company})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.Entity{type: :company}, ...]}

      iex> list_entities(search: "my")
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.Entity{name: "My company"}, ...]}

  """
  @spec list_entities(keyword) :: Paginator.Page.t(entity())
  def list_entities(options \\ []) do
    from(e in Entities.Entity)
    |> build_filter(Keyword.get(options, :filter), [:type, :status])
    |> build_search(Keyword.get(options, :search), [:name])
    |> Paginator.paginate(options)
  end

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of entities in the
  `:entries` field from the given user.

  ## Expected arguments

  * user - A `%Cashtrail.Users.User{}` that owns or is member of the entity.
  * options - A `keyword` list of the following options:
    * `:filter` => filters by following attributes:
      * `:type` or `"type"`
      * `:status` or `"status"`
    * `:search` => search entities by `:name`.
    * `:relation_type` => filter by relation type, that can be:
      * `:owner` => list only entities owned by the user.
      * `:member` => list only entities that the user is member of.
      * `:both` => the default value, list entities that the user is owned by or
      is member of the entities.
    * See `Cashtrail.Paginator.paginate/2` to see paginations options.

  See `Cashtrail.Entities.Entity` to have more detailed info about the fields to
  be filtered or searched.

  ## Examples

      iex> list_entities_for(owner)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.Entity{}, ...]}

      iex> list_entities_for(member)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.Entity{}, ...]}

  """
  @spec list_entities_for(user, keyword) :: Paginator.Page.t(entity())
  def list_entities_for(%Users.User{id: user_id}, options \\ []) do
    from(e in Entities.Entity)
    |> build_filter(Keyword.get(options, :filter), [:type, :status])
    |> build_search(Keyword.get(options, :search), [:name])
    |> of_relation(user_id, Keyword.get(options, :relation_type, :both))
    |> Paginator.paginate(options)
  end

  defp of_relation(query, user_id, :owner) do
    where(query, [e], e.owner_id == ^user_id)
  end

  defp of_relation(query, user_id, :member) do
    query
    |> join(:left, [e], m in assoc(e, :members))
    |> where([_, m], m.user_id == ^user_id)
  end

  defp of_relation(query, user_id, _) do
    query
    |> join(:left, [e], m in assoc(e, :members))
    |> where([e, m], e.owner_id == ^user_id or m.user_id == ^user_id)
  end

  @doc """
  Gets a single entity.

  Raises `Ecto.NoResultsError` if the Entity does not exist.

  See `Cashtrail.Entities.Entity` to have more detailed info about the returned
  struct.

  ## Expected Arguments

  * id - A `string` that is the unique id of the entity to be found.

  ## Examples

      iex> get_entity!(123)
      %Cashtrail.Entities.Entity{}

      iex> get_entity!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_entity!(Ecto.UUID.t()) :: entity()
  def get_entity!(id), do: Repo.get!(Entities.Entity, id)

  @doc """
  Creates an entity.

  ## Expected Arguments

  * params - A `map` with the params of the entity to be created:
    * `:name` (required) - A `string` with the name or description of the entity.
    * `:type` - A `string` with the type of the entity. It can be `:personal`,
    `:company` or `:other`. Defaults to `:personal`.
    * `:owner_id` - A `string` that references to the `Cashtrail.Users.User` that
    is the owner of the entity.

  See `Cashtrail.Entities.Entity` to have more detailed info about the fields.

  ## Returns

  * `{:ok, %Cashtrail.Entities.Entity{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> create_entity(user, %{field: value})
      {:ok, %Cashtrail.Entities.Entity{}}

      iex> create_entity(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_entity(user, map, boolean) ::
          {:ok, entity()} | {:error, Ecto.Changeset.t(entity())}
  def create_entity(user, attrs, create_tenants \\ true)

  def create_entity(%Users.User{} = user, attrs, true) do
    with {:ok, entity} <- create_entity(user, attrs, false),
         {:ok, _tenant} <- Entities.Tenants.create(entity) do
      {:ok, entity}
    end
  end

  def create_entity(%Users.User{id: user_id}, attrs, false) do
    %Entities.Entity{owner_id: user_id}
    |> Entities.Entity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an entity.

  ## Expected Arguments

  * user - The `%Cashtrail.Entities.Entity{}` to be updated.
  * params - A `map` with the field of the entity to be updated. See
  `create_entity/2` to know about the params that can be given.

  ## Returns

  * `{:ok, %Cashtrail.Entities.Entity{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> update_entity(entity, %{field: new_value})
      {:ok, %Cashtrail.Entities.Entity{}}

      iex> update_entity(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_entity(entity(), map) :: {:ok, entity()} | {:error, Ecto.Changeset.t(entity())}
  def update_entity(%Entities.Entity{} = entity, attrs) do
    entity
    |> Entities.Entity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an entity.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` to be deleted.

  ## Returns

  * `{:ok, %Cashtrail.Entities.Entity{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> delete_entity(entity)
      {:ok, %Cashtrail.Entities.Entity{}}

      iex> delete_entity(entity)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_entity(entity()) ::
          {:ok, entity()}
          | {:error, Ecto.Changeset.t(entity())}
  def delete_entity(entity, drop_tenants \\ true)

  def delete_entity(%Entities.Entity{} = entity, true) do
    with {:ok, entity} <- delete_entity(entity, false),
         {:ok, _tenant} <- Entities.Tenants.drop(entity) do
      {:ok, entity}
    end
  end

  def delete_entity(%Entities.Entity{} = entity, false) do
    Repo.delete(entity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entity changes.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` to be tracked.

  ## Examples

      iex> change_entity(entity)
      %Ecto.Changeset{source: %Cashtrail.Entities.Entity{}}

  """
  @spec change_entity(entity()) :: Ecto.Changeset.t(entity())
  def change_entity(%Entities.Entity{} = entity) do
    Entities.Entity.changeset(entity, %{})
  end

  @doc """
  Transfer the ownership of an entity from one user to another.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` to be transfered.
  * from_user - The `%Cashtrail.Users.User{}` to be transfered.
  * to_user - The `%Cashtrail.Users.User{}` to be transfered.

  ## Returns
    * `{:ok, %Cashtrail.Entities.Entity{}}` if the entity is transfered successfully.
    * `{:error, changeset}` if to_user is invalid or it's not found.
    * `{:error, :unauthorized}` if from_user is not the owner of the entity.

  ## Effects

  After the ownership transference, the previous owner (`from_user`) becomes a
  member of the entity with `:admin` permissions.

  ## Examples

      iex> transfer_ownership(entity, from_user, to_user)
      {:ok, %Cashtrail.Entities.Entity{}}

      iex> transfer_ownership(entity, from_user, to_user)
      {:error, %Ecto.Changeset{source: %Cashtrail.Entities.Entity{}}}

      iex> transfer_ownership(entity, invalid_from, to_user)
      {:error, :unauthorized}
  """
  @spec transfer_ownership(entity, user, user) ::
          {:error, :unauthorized} | {:ok, entity()}
  def transfer_ownership(
        %Entities.Entity{} = entity,
        %Users.User{id: from_user_id} = from_user,
        %Users.User{id: to_user_id} = to_user
      ) do
    if entity.owner_id == from_user_id do
      changeset = Entities.Entity.transfer_changeset(entity, %{owner_id: to_user_id})

      with {:ok, entity} <- Repo.update(changeset) do
        remove_member(entity, to_user)
        add_member(entity, from_user, :admin)

        {:ok, entity}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns a `boolean` that says if the entity belongs to the user.

  ## Expected Arguments

  * user - The `%Cashtrail.Users.User{}` to be deleted.

  ## Examples

      iex> belongs_to?(%Cashtrail.Entities.Entity{owner_id: "aaa"}, %Cashtrail.Users.User{id: "aaa"})
      true

      iex> belongs_to?(%Cashtrail.Entities.Entity{owner_id: "bbb"}, %Cashtrail.Users.User{id: "aaa"})
      false
  """
  @spec belongs_to?(entity, user) :: boolean
  def belongs_to?(%Entities.Entity{owner_id: owner_id}, %Users.User{id: user_id}) do
    owner_id == user_id
  end

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of entity_members in the
  `:entries` field.

  ## Expected arguments

  * options - A `keyword` list of the following options:
    * `:filter` => filters by following attributes:
      * `:permission` or `"permission"`
    * `:search` => search users by its user `:name`.
    * See `Cashtrail.Paginator.paginate/2` to see paginations options.

  See `Cashtrail.Entities.EntityMember` to have more detailed info about the
  fields to be filtered or searched.

  ## Examples

      iex> list_entity_members(entity)
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.EntityMember{}, ...]}

      iex> list_entity_members(entity, filter: %{permission: :read})
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.EntityMember{permission: :read}, ...]}

      iex> list_entity_members(entity, search: "my")
      %Cashtrail.Paginator.Page{entries: [%Cashtrail.Entities.EntityMember{user: %Cashtrail.Users.User{name: "My Name"}}, ...]}

  """
  @spec list_members(entity, keyword | map) :: Paginator.Page.t(entity_member)
  def list_members(%Entities.Entity{id: entity_id}, options \\ []) do
    from(Entities.EntityMember, where: [entity_id: ^entity_id])
    |> build_filter(Keyword.get(options, :filter), [:permission])
    |> search_members(Keyword.get(options, :search))
    |> Paginator.paginate(options)
  end

  defp search_members(query, term) when is_binary(term) do
    term = "%#{term}%"

    from q in query,
      join: u in assoc(q, :user),
      where: ilike(u.first_name, ^term) or ilike(u.last_name, ^term) or ilike(u.email, ^term)
  end

  defp search_members(query, _), do: query

  @doc """
  Creates an entity_member for the entity.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the member will be created.
  * params - A `map` with the params of the user to be created:
    * `:permission` (required) - a `string` with the permission that will be given
    to the member. It can be: `:read`, `:write` or `:admin`.
    * `:user_id` - A `string` with a reference to one `Cashtrail.Users.User` to
    be added as a member to the entity.
    * `:user` - A `map` of the `Cashtrail.Users.User` that should be created as a
    member of the entity. See `Cashtrail.Users.create_user/1` docs to know more
    about the accepted params.

  See `Cashtrail.Entities.EntityMember` to have more detailed info about the fields.

  ## Returns

  * `{:ok, %Cashtrail.Entities.EntityMember{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> create_member(entity, %{field: value})
      {:ok, %Cashtrail.Entities.EntityMember{}}

      iex> create_member(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_member(entity, map) ::
          {:ok, entity_member} | {:error, Ecto.Changeset.t(entity_member)}
  def create_member(%Entities.Entity{} = entity, attrs) do
    email = get_in(attrs, [:user, :email]) || get_in(attrs, ["user", "email"])

    attrs =
      case Users.get_user_by(email: email) do
        %Users.User{} = user ->
          attrs |> Map.delete(:user) |> Map.delete("user") |> Map.put(:user_id, user.id)

        _ ->
          attrs
      end

    entity
    |> Ecto.build_assoc(:members)
    |> Entities.EntityMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Add a user as an entity_member for the entity giving permission.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the member will be added.
  * user - A `%Cashtrail.Users.User{}` that is the user to be added as a member.
  The user cannot be the owner of the entity, otherwise, it will return an error.
  * permission - A `string` with the permission that will be given to the member.
  It can be: `:read`, `:write` or `:admin`.

  See `Cashtrail.Entities.EntityMember` to have more detailed info about the
  permissions.

  ## Returns

  * `{:ok, %Cashtrail.Entities.EntityMember{}}` in case of success.
  * `{:error, :invalid}` in case of the user be the owner of the entity.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> add_member(entity, user)
      {:ok, %Cashtrail.Entities.EntityMember{}}

      iex> add_member(entity, invalid_user)
      {:error, %Ecto.Changeset{}}

  """
  @spec add_member(entity, user, String.t() | entity_member_permission) ::
          {:ok, entity_member} | {:error, :invalid | Ecto.Changeset.t(entity)}
  def add_member(entity, user, permission \\ :read)

  def add_member(%Entities.Entity{owner_id: owner_id}, %Users.User{id: user_id}, _)
      when owner_id == user_id do
    {:error, :invalid}
  end

  def add_member(%Entities.Entity{} = entity, %Users.User{id: user_id}, permission) do
    entity
    |> Ecto.build_assoc(:members)
    |> Entities.EntityMember.changeset(%{user_id: user_id, permission: permission})
    |> Repo.insert()
  end

  @doc """
  Removes an entity_member from the entity.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the member will be removed.
  * user - A `%Cashtrail.Users.User{}` that is the user to be removed as a member
  of the given entity.

  ## Returns

  * `{:ok, %Cashtrail.Entities.EntityMember{}}` in case of success.
  * `{:error, :not_found}` if the user is not a member of the entity.

  ## Examples

      iex> delete_entity_member(entity_member)
      {:ok, %Cashtrail.Entities.EntityMember{}}

      iex> delete_entity_member(entity_member)
      {:error, :not_found}

  """
  @spec remove_member(entity, user) ::
          {:ok, entity_member} | {:error, :not_found}
  def remove_member(%Entities.Entity{} = entity, %Users.User{} = user) do
    case member_from_user(entity, user) do
      %Entities.EntityMember{} = entity_member -> Repo.delete(entity_member)
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Updates the member's permission.

  If the user is not a member or is the owner, it returns an error. The owner will always
  have admin permission.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the member will have the
  permissions updated.
  * user - A `%Cashtrail.Users.User{}` that is the user to have the permissions
  updated.
  * permission - A `string` with the permission that will be given
    to the member. It can be: `:read`, `:write` or `:admin`.

  ## Returns

  * `{:ok, %Cashtrail.Entities.EntityMember{}}` in case of success.
  * `{:error, :invalid}` if the user is the owner of the entity.
  * `{:error, :not_found}` if the user is not a member of the entity.
  * `{:error, %Ecto.Changeset{}}` in case of validation errors.


  ## Examples

      iex> update_member_permission(entity, user, "write")
      {:ok, %EntityMember{}}

      iex> update_member_permission(entity, user, :write)
      {:ok, %EntityMember{}}

      iex> update_member_permission(entity, user, :invalid)
      {:error, %Ecto.Changeset{}}

      iex> update_member_permission(entity, owner, :write)
      {:error, :invalid}

      iex> update_member_permission(entity, another_user, :write)
      {:error, :not_found}
  """
  @spec update_member_permission(entity, user, String.t() | entity_member_permission) ::
          {:ok, entity_member} | {:error, Ecto.Changeset.t(entity_member) | :invalid | :not_found}
  def update_member_permission(
        %Entities.Entity{owner_id: owner_id} = entity,
        %Users.User{id: user_id} = user,
        permission
      ) do
    case member_from_user(entity, user) do
      %Entities.EntityMember{} = entity_member ->
        entity_member
        |> Entities.EntityMember.changeset(%{permission: permission})
        |> Repo.update()

      _ when owner_id == user_id ->
        {:error, :invalid}

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns the member permission as an atom or :unauthorized if the member is not
  found. If the user is the owner, return permission as :admin.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the member belongs.
  * user - The `%Cashtrail.Users.User{}` to know the permission.

  ## Examples

      iex> get_member_permission(entity, user)
      :admin

      iex> get_member_permission(entity, another_user)
      :unauthorized
  """
  @spec get_member_permission(entity, user) :: atom
  def get_member_permission(
        %Entities.Entity{owner_id: owner_id} = entity,
        %Users.User{id: user_id} = user
      ) do
    case member_from_user(entity, user) do
      %Entities.EntityMember{} = entity_member ->
        entity_member.permission

      _ when owner_id == user_id ->
        :admin

      _ ->
        :unauthorized
    end
  end

  @doc """
  Returns the `%Cashtrail.Entities.EntityMember{}` from the user and the entity. Returns
  `nil` if the user is not a member of the entity or if it is the owner.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the member belongs.
  * user - The `%Cashtrail.Users.User{}` to have the entity_member found.

  ## Examples

      iex> member_from_user(entity, user)
      %Cashtrail.Entities.EntityMember{}

      iex> member_from_user(entity, owner)
      nil

      iex> member_from_user(entity, non_member_user)
      nil
  """
  @spec member_from_user(entity, user) ::
          entity_member | nil
  def member_from_user(%Entities.Entity{id: entity_id}, %Users.User{id: user_id}) do
    Repo.get_by(Entities.EntityMember, entity_id: entity_id, user_id: user_id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entity_member changes.

  ## Expected Arguments

  * entity_member - The `%Cashtrail.Entities.EntityMember{}` to be tracked.

  ## Examples

      iex> change_member(entity_member)
      %Ecto.Changeset{source: %Cashtrail.Entities.EntityMember{}}

  """
  @spec change_member(entity_member) :: Ecto.Changeset.t(entity_member)
  def change_member(%Entities.EntityMember{} = entity_member) do
    Entities.EntityMember.changeset(entity_member, %{})
  end
end
