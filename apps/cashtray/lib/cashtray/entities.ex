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
end
