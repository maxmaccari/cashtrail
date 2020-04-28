defmodule Cashtray.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Contacts.Category
  alias Cashtray.Paginator

  import Cashtray.Entities.Tenants, only: [to_prefix: 1]

  @type category :: Category.t()

  @doc """
  Returns the list of contact_categories.

  ## Examples

      iex> list_categories(entity)
      %Cashtray.Paginator{entries: [%Category{}, ...]}

  """
  @spec list_categories(Cashtray.Entities.Entity.t()) :: Cashtray.Paginator.Page.t()
  def list_categories(entity, options \\ []) do
    Cashtray.Contacts.Category
    |> Ecto.Queryable.to_query()
    |> Map.put(:prefix, to_prefix(entity))
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(entity, 123)
      %Category{}

      iex> get_category!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(entity, id), do: Repo.get!(Category, id, prefix: to_prefix(entity))

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(entity, %{field: value})
      {:ok, %Category{}}

      iex> create_category(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(entity, attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end
