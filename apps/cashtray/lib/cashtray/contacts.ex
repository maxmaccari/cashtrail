defmodule Cashtray.Contacts do
  @moduledoc """
  The Contacts context is responsible to manage the contacts linked to transactions.
  """

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Contacts.Category
  alias Cashtray.Paginator

  import Cashtray.Entities.Tenants, only: [to_prefix: 1, put_prefix: 2]

  @type category :: Category.t()

  @doc """
  Returns the list of contact categories.

  You must pass the entity to find the contacts categories correctely.

  Options:
    * `:search` => search accounts by `:description`
    * See `Cashtray.Paginator.paginate/2` to see paginations options

  ## Examples

      iex> list_categories(entity)
      %Cashtray.Paginator{entries: [%Contacts.Category{}, ...]}

      iex> list_categories(entity, search: "My desc")
      %Cashtray.Paginator{entries: [%Contacts.Category{description: "My Description"}, ...]}

  """
  @spec list_categories(Cashtray.Entities.Entity.t()) :: Cashtray.Paginator.Page.t()
  def list_categories(entity, options \\ []) do
    Cashtray.Contacts.Category
    |> search_category(Keyword.get(options, :search))
    |> put_prefix(entity)
    |> Paginator.paginate(options)
  end

  defp search_category(query, term) when is_binary(term) do
    term = "%#{term}%"
    from(q in query, where: ilike(q.description, ^term))
  end

  defp search_category(query, _), do: query

  @doc """
  Gets a single category.

  You must pass the entity to get the contact category correctely.

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

  You must pass the entity to create the contact category correctely.

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

  alias Cashtray.Contacts.Contact

  @doc """
  Returns the list of contacts.

  You must pass the entity to find the contacts correctely.

  Options:
    * `:filter` => filters by following attributes:
      * `:type` or `"type"`
      * `:customer` or `"customer"`
      * `:supplier` or `"supplier"`
    * `:search` => search accounts by `:name` or `:legal_name`
    * See `Cashtray.Paginator.paginate/2` to see paginations options

  ## Examples

      iex> list_contacts(entity)
      %Cashtray.Paginator{entries: [%Contact{}, ...]}

      iex> list_contacts(entity, filter: %{type: "company"})
      %Cashtray.Paginator{entries: [%Contact{type: "company"}, ...]}

      iex> list_contacts(entity, search: "my")
      %Cashtray.Paginator{entries: [%Contact{name: "My name"}, ...]}

  """
  def list_contacts(entity, options \\ []) do
    Contact
    |> filter_contact(Keyword.get(options, :filter))
    |> search_contact(Keyword.get(options, :search))
    |> put_prefix(entity)
    |> Paginator.paginate(options)
  end

  defp filter_contact(query, filters) when is_map(filters) do
    Enum.reduce(filters, query, fn
      {"type", value}, query -> from(q in query, where: [type: ^value])
      {:type, value}, query -> from(q in query, where: [type: ^value])
      {"customer", value}, query -> from(q in query, where: [customer: ^value])
      {:customer, value}, query -> from(q in query, where: [customer: ^value])
      {"supplier", value}, query -> from(q in query, where: [supplier: ^value])
      {:supplier, value}, query -> from(q in query, where: [supplier: ^value])
      _, query -> query
    end)
  end

  defp filter_contact(query, _), do: query

  defp search_contact(query, term) when is_binary(term) do
    term = "%#{term}%"
    from(q in query, where: ilike(q.name, ^term) or ilike(q.legal_name, ^term))
  end

  defp search_contact(query, _), do: query

  @doc """
  Gets a single contact.

  You must pass the entity to get the contact correctely.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(entity, 123)
      %Contact{}

      iex> get_contact!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(entity, id), do: Repo.get!(Contact, id, prefix: to_prefix(entity))

  @doc """
  Creates a contact.

  You must pass the entity to create the contact correctely.

  ## Examples

      iex> create_contact(entity, %{field: value})
      {:ok, %Contact{}}

      iex> create_contact(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(entity, attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end
end
