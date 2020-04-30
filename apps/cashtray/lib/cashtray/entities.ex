defmodule Cashtray.Entities do
  @moduledoc """
  The Entities context manages data related to entities. An Entity keeps all
  financial data of something, that can be a company, financial finances,
  organization, church, event, etc.

  They can have one owner or other members.
  """

  @type entity :: Cashtray.Entities.Entity.t()
  @type entity_member :: Cashtray.Entities.EntityMember.t()

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Accounts.User
  alias Cashtray.Entities.{Entity, EntityMember, Tenants}
  alias Cashtray.Paginator

  @doc """
  Returns a list of all entities.

  Options:
    * `:filter` => filters by following attributes:
      * `:type` or `"type"`
      * `:status` or `"status"`
    * `:search` => search accounts by `:name`
    * See `Cashtray.Paginator.paginate/2` to see paginations options

  ## Examples

      iex> list_entities()
      %Cashtray.Paginator.Page{entries: [%Entity{}, ...]}

      iex> list_entities(filter: %{type: "company"})
      %Cashtray.Paginator.Page{entries: [%Entity{type: "company"}, ...]}

      iex> list_entities(search: "my")
      %Cashtray.Paginator.Page{entries: [%Entity{name: "My company"}, ...]}

  """
  @spec list_entities(keyword) :: Paginator.Page.t(entity())
  def list_entities(options \\ []) do
    from(e in Entity)
    |> filter_entities(Keyword.get(options, :filter))
    |> search_entities(Keyword.get(options, :search))
    |> Paginator.paginate(options)
  end

  defp filter_entities(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn
      {"type", value}, query -> from(q in query, where: [type: ^value])
      {:type, value}, query -> from(q in query, where: [type: ^value])
      {"status", value}, query -> from(q in query, where: [status: ^value])
      {:status, value}, query -> from(q in query, where: [status: ^value])
      _, query -> query
    end)
  end

  defp filter_entities(query, _), do: query

  defp search_entities(query, term) when is_binary(term) do
    term = "%#{term}%"
    from(q in query, where: ilike(q.name, ^term))
  end

  defp search_entities(query, _), do: query

  @doc """
  Returns a list of entities from the given user.

  Options:
    * `:filter` => filters by following attributes:
      * `:type` or `"type"`
      * `:status` or `"status"`
    * `:search` => search accounts by `:name`
    * See `Cashtray.Paginator.paginate/2` to see paginations options

  ## Examples

      iex> list_entities_from(owner)
      %Cashtray.Paginator.Page{entries: [%Entity{}, ...]}

      iex> list_entities_from(member)
      %Cashtray.Paginator.Page{entries: [%Entity{}, ...]}

  """
  @spec list_entities_from(Cashtray.Accounts.User.t(), keyword) :: Paginator.Page.t(entity())
  def list_entities_from(%User{} = user, params \\ []) do
    from(e in Entity)
    |> join(:left, [e], m in assoc(e, :members))
    |> or_where([e], e.owner_id == ^user.id)
    |> or_where([e, m], m.user_id == ^user.id)
    |> Paginator.paginate(params)
  end

  @doc """
  Gets a single entity.

  Raises `Ecto.NoResultsError` if the Entity does not exist.

  ## Examples

      iex> get_entity!(123)
      %Entity{}

      iex> get_entity!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_entity!(Ecto.UUID.t()) :: entity()
  def get_entity!(id), do: Repo.get!(Entity, id)

  @doc """
  Creates a entity.

  ## Examples

      iex> create_entity(user, %{field: value})
      {:ok, %Entity{}}

      iex> create_entity(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_entity(Cashtray.Accounts.User.t(), map, boolean) ::
          {:ok, entity()} | {:error, Ecto.Changeset.t(entity())}
  def create_entity(user, attrs \\ %{}, create_tenants \\ true)

  def create_entity(%User{} = user, attrs, true) do
    with {:ok, entity} <- create_entity(user, attrs, false),
         {:ok, _tenant} <- Tenants.create(entity) do
      {:ok, entity}
    end
  end

  def create_entity(%User{} = user, attrs, false) do
    user
    |> Ecto.build_assoc(:entities)
    |> Entity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a entity.

  ## Examples

      iex> update_entity(entity, %{field: new_value})
      {:ok, %Entity{}}

      iex> update_entity(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_entity(entity(), map) :: {:ok, entity()} | {:error, Ecto.Changeset.t(entity())}
  def update_entity(%Entity{} = entity, attrs) do
    entity
    |> Entity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entity.

  ## Examples

      iex> delete_entity(entity)
      {:ok, %Entity{}}

      iex> delete_entity(entity)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_entity(entity()) ::
          {:ok, entity()}
          | {:error, Ecto.Changeset.t(entity())}
  def delete_entity(entity, drop_tenants \\ true)

  def delete_entity(%Entity{} = entity, true) do
    with {:ok, entity} <- delete_entity(entity, false),
         {:ok, _tenant} <- Tenants.drop(entity) do
      {:ok, entity}
    end
  end

  def delete_entity(%Entity{} = entity, false) do
    Repo.delete(entity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entity changes.

  ## Examples

      iex> change_entity(entity)
      %Ecto.Changeset{source: %Entity{}}

  """
  @spec change_entity(entity()) :: Ecto.Changeset.t(entity())
  def change_entity(%Entity{} = entity) do
    Entity.changeset(entity, %{})
  end

  @doc """
  Transfer the ownership of a entity from one user to another.

  Returns:
    * {:ok, %Entity{}} if the entity is transfered successfully.
    * {:error, changeset} if to user is invalid or it's not found.
    * {:error, :unauthorized} if from user is not the owner of the entity.

  ## Examples

      iex> transfer_ownership(entity, from, to)
      {:ok, %Entity{}}

      iex> transfer_ownership(entity, from, to)
      {:error, %Ecto.Changeset{source: %Entity{}}}

      iex> transfer_ownership(entity, invalid_from, to)
      {:error, :unauthorized}
  """
  @spec transfer_ownership(entity(), Cashtray.Accounts.User.t(), Cashtray.Accounts.User.t()) ::
          {:error, :unauthorized} | {:ok, entity()}
  def transfer_ownership(%Entity{} = entity, %User{} = from, %User{} = to) do
    if entity.owner_id == from.id do
      changeset = Entity.transfer_changeset(entity, %{owner_id: to.id})

      with {:ok, entity} <- Repo.update(changeset) do
        remove_member(entity, to)
        add_member(entity, from, "admin")

        {:ok, entity}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Display if the entity belongs to the user

  ## Examples

    iex> belongs_to?(%Entity{owner_id: "aaa"}, %User{id: "aaa"})
    true

    iex> belongs_to?(%Entity{owner_id: "bbb"}, %User{id: "aaa"})
    false
  """
  @spec belongs_to?(entity(), Cashtray.Accounts.User.t()) :: boolean
  def belongs_to?(%Entity{owner_id: owner_id}, %User{id: user_id}) do
    owner_id == user_id
  end

  alias Cashtray.Accounts

  @doc """
  Returns a list of entity_members from the given entity.

  Options:
    * `:filter` => filters by following attributes:
      * `:permission` or `"permission"`
    * `:search` => search accounts by its user `:name`
    * See `Cashtray.Paginator.paginate/2` to see paginations options
  ## Examples

      iex> list_entity_members(entity)
      %Cashtray.Paginator.Page{entries: [%EntityMember{}, ...]}

      iex> list_entity_members(entity, filter: %{permission: "read"})
      %Cashtray.Paginator.Page{entries: [%EntityMember{permission: "read"}, ...]}

      iex> list_entity_members(entity, search: "my")
      %Cashtray.Paginator.Page{entries: [%EntityMember{user: %Accounts.User{name: "My Name"}}, ...]}

  """
  @spec list_members(entity, keyword | map) :: Paginator.Page.t(entity_member)
  def list_members(%Entity{id: entity_id}, options \\ []) do
    from(EntityMember, where: [entity_id: ^entity_id])
    |> filter_members(Keyword.get(options, :filter))
    |> search_members(Keyword.get(options, :search))
    |> Paginator.paginate(options)
  end

  defp filter_members(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn
      {"permission", value}, query -> from(q in query, where: [permission: ^value])
      {:permission, value}, query -> from(q in query, where: [permission: ^value])
      _, query -> query
    end)
  end

  defp filter_members(query, _), do: query

  defp search_members(query, term) when is_binary(term) do
    term = "%#{term}%"

    from q in query,
      join: u in assoc(q, :user),
      where: ilike(u.first_name, ^term) or ilike(u.last_name, ^term) or ilike(u.email, ^term)
  end

  defp search_members(query, _), do: query

  @doc """
  Creates a entity_member for the entity.

  ## Examples

      iex> create_member(entity, %{field: value})
      {:ok, %EntityMember{}}

      iex> create_member(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_member(entity, map) ::
          {:ok, entity_member} | {:error, Ecto.Changeset.t(entity_member)}
  def create_member(%Entity{} = entity, attrs \\ %{}) do
    email = get_in(attrs, [:user, :email]) || get_in(attrs, ["user", "email"])

    attrs =
      case Accounts.get_user_by(email: email) do
        %User{} = user ->
          attrs |> Map.delete(:user) |> Map.delete("user") |> Map.put(:user_id, user.id)

        _ ->
          attrs
      end

    entity
    |> Ecto.build_assoc(:members)
    |> EntityMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a entity_member for the entity, the user and the permission.

  Returns %Ecto.Changeset{} if the given user is invalid or is already added
  Returns :invalid if the given user is the owner of the entity

  ## Examples

      iex> add_member(entity, user)
      {:ok, %EntityMember{}}

      iex> add_member(entity, invalid_user)
      {:error, %Ecto.Changeset{}}

  """
  @spec add_member(entity, Cashtray.Accounts.User.t()) ::
          {:ok, entity_member} | {:error, :invalid | Ecto.Changeset.t(entity)}
  def add_member(%Entity{owner_id: owner_id}, %User{id: user_id}) when owner_id == user_id do
    {:error, :invalid}
  end

  def add_member(%Entity{} = entity, %User{id: user_id}, permission \\ "read") do
    entity
    |> Ecto.build_assoc(:members)
    |> EntityMember.changeset(%{user_id: user_id, permission: permission})
    |> Repo.insert()
  end

  @doc """
  Deletes a entity_member.

  If entity member is not found, it returns a error

  ## Examples

      iex> delete_entity_member(entity_member)
      {:ok, %EntityMember{}}

      iex> delete_entity_member(entity_member)
      {:error, :not_found}

  """
  @spec remove_member(entity, Cashtray.Accounts.User.t()) ::
          {:ok, entity_member} | {:error, :not_found}
  def remove_member(entity, user) do
    case member_from_user(entity, user) do
      %EntityMember{} = entity_member -> Repo.delete(entity_member)
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Updates the member permission.

  If the user is not member or is the owner, returns error. The owner always
  will have the admin permission.

  ## Examples

    iex> update_member_permission(entity, user, "write")
    {:ok, %EntityMember{}}

    iex> update_member_permission(entity, user, "invalid")
    {:error, %Ecto.Changeset{}}

    iex> update_member_permission(entity, owner, "write")
    {:error, :invalid}

    iex> update_member_permission(entity, another_user, "write)
    {:error, :not_found}
  """
  @spec update_member_permission(entity, Cashtray.Accounts.User.t(), String.t()) ::
          {:ok, entity_member} | {:error, Ecto.Changeset.t(entity_member) | :invalid | :not_found}
  def update_member_permission(
        %Entity{owner_id: owner_id} = entity,
        %User{id: user_id} = user,
        permission
      ) do
    case member_from_user(entity, user) do
      %EntityMember{} = entity_member ->
        entity_member
        |> EntityMember.changeset(%{permission: permission})
        |> Repo.update()

      _ when owner_id == user_id ->
        {:error, :invalid}

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns the member permission as a atom or :unauthorized if the member is not
  found.

  If the user is the owner, returns the permission as :admin

  ## Examples

    iex> get_member_permission(entity, user)
    :admin

    iex> get_member_permission(entity, another_user)
    :unauthorized
  """
  @spec get_member_permission(entity(), Cashtray.Accounts.User.t()) :: atom()
  def get_member_permission(%Entity{owner_id: owner_id} = entity, %User{id: user_id} = user) do
    case member_from_user(entity, user) do
      %EntityMember{} = entity_member ->
        # For security reasons to avoid reach the atom limit
        _trusted_values = [:read, :write, :admin]
        String.to_existing_atom(entity_member.permission)

      _ when owner_id == user_id ->
        :admin

      _ ->
        :unauthorized
    end
  end

  @doc """
  Returns the member struct from the user and the entity. Returns nil if the user is
  not a member from the entity or is the owner.

  ## Examples

    iex> member_from_user(entity, user)
    %EntityMember{}

    iex> member_from_user(entity, owner)
    nil

    iex> member_from_user(entity, non_member_user)
    nil
  """
  @spec member_from_user(entity(), Cashtray.Accounts.User.t()) ::
          entity_member | nil
  def member_from_user(%Entity{id: entity_id}, %User{id: user_id}) do
    Repo.get_by(EntityMember, entity_id: entity_id, user_id: user_id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entity_member changes.

  ## Examples

      iex> change_member(entity_member)
      %Ecto.Changeset{source: %EntityMember{}}

  """
  @spec change_member(entity_member()) :: Ecto.Changeset.t(entity_member())
  def change_member(%EntityMember{} = entity_member) do
    EntityMember.changeset(entity_member, %{})
  end
end
