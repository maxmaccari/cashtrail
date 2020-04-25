defmodule Cashtray.Entities do
  @moduledoc """
  The Entities context.
  """

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Entities.Entity
  alias Cashtray.Accounts.User

  @doc """
  Returns the list of entities from the given user.

  ## Examples

      iex> list_entities(owner)
      [%Entity{}, ...]

  """
  def list_entities_from(%User{} = owner) do
    Repo.all(from(Entity, where: [owner_id: ^owner.id]))
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
  def get_entity!(id), do: Repo.get!(Entity, id)

  @doc """
  Creates a entity.

  ## Examples

      iex> create_entity(%{field: value})
      {:ok, %Entity{}}

      iex> create_entity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entity(%User{} = user, attrs \\ %{}) do
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
  def delete_entity(%Entity{} = entity) do
    Repo.delete(entity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entity changes.

  ## Examples

      iex> change_entity(entity)
      %Ecto.Changeset{source: %Entity{}}

  """
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
  def transfer_ownership(%Entity{} = entity, %User{} = from, %User{} = to) do
    cond do
      entity.owner_id == from.id ->
        # TODO: remove to member if it his a member
        # TODO: set from as a member with :admin permission
        entity
        |> Entity.transfer_changeset(%{owner_id: to.id})
        |> Repo.update()

      true ->
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
  def belongs_to?(%Entity{owner_id: owner_id}, %User{id: user_id}) do
    owner_id == user_id
  end

  alias Cashtray.Accounts
  alias Cashtray.Entities.EntityMember

  @doc """
  Returns the list of entity_members.

  ## Examples

      iex> list_entity_members()
      [%EntityMember{}, ...]

  """
  def list_members(%Entity{id: entity_id}) do
    Repo.all(from EntityMember, where: [entity_id: ^entity_id])
  end

  @doc """
  Creates a entity_member for the entity.

  ## Examples

      iex> create_member(entity, %{field: value})
      {:ok, %EntityMember{}}

      iex> create_member(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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

  Returns %Ecto.Changeset{} if the given user_id is invalid or is already added

  ## Examples

      iex> add_member(entity, user)
      {:ok, %EntityMember{}}

      iex> add_member(entity, invalid_user)
      {:error, %Ecto.Changeset{}}

  """
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
  def remove_member(%Entity{id: entity_id}, %User{id: user_id}) do
    case Repo.get_by(EntityMember, entity_id: entity_id, user_id: user_id) do
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
    {:ok, %Entity{}}

    iex> update_member_permission(entity, user, "invalid")
    {:error, %Error.Changeset{}}

    iex> update_member_permission(entity, owner, "write")
    {:error, :invalid}

    iex> update_member_permission(entity, another_user, "write)
    {:error, :not_found}
  """
  def update_member_permission(
        %Entity{id: entity_id, owner_id: owner_id},
        %User{id: user_id},
        permission
      ) do
    case Repo.get_by(EntityMember, entity_id: entity_id, user_id: user_id) do
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
  def get_member_permission(%Entity{id: entity_id, owner_id: owner_id}, %User{id: user_id}) do
    case Repo.get_by(EntityMember, entity_id: entity_id, user_id: user_id) do
      %EntityMember{} = entity_member ->
        _trusted_values = [:read, :write, :admin]
        String.to_existing_atom(entity_member.permission)

      _ when owner_id == user_id ->
        :admin

      _ ->
        :unauthorized
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entity_member changes.

  ## Examples

      iex> change_member(entity_member)
      %Ecto.Changeset{source: %EntityMember{}}

  """
  def change_member(%EntityMember{} = entity_member) do
    EntityMember.changeset(entity_member, %{})
  end
end
