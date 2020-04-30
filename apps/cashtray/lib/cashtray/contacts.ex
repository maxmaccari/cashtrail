defmodule Cashtray.Contacts do
  @moduledoc """
  The Contacts context is responsible to manage the contacts linked to transactions.
  """

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Entities.Entity
  alias Cashtray.Contacts.Category
  alias Cashtray.Paginator

  import Cashtray.Entities.Tenants, only: [to_prefix: 1, put_prefix: 2]

  @type category :: Category.t()

  @doc """
  Returns the list of contact categories.

  You must pass the entity to find the contacts categories correctely.

  ## Options
    * `:search` - search accounts by `:description`
    * See `Cashtray.Paginator.paginate/2` to see the paginations options

  ## Examples

      iex> list_categories(entity)
      %Cashtray.Paginator{entries: [%Contacts.Category{}, ...]}

      iex> list_categories(entity, search: "My desc")
      %Cashtray.Paginator{entries: [%Contacts.Category{description: "My Description"}, ...]}

  """
  @spec list_categories(Cashtray.Entities.Entity.t()) :: Cashtray.Paginator.Page.t(category)
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
  @spec get_category!(Entity.t(), integer) :: category
  def get_category!(%Entity{} = entity, id),
    do: Repo.get!(Category, id, prefix: to_prefix(entity))

  @doc """
  Creates a category.

  You must pass the entity to create the contact category correctely.

  ## Params
    * `:description` (required)

  ## Examples

      iex> create_category(entity, %{field: value})
      {:ok, %Category{}}

      iex> create_category(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_category(Entity.t(), map) ::
          {:ok, category} | {:error, Ecto.Changeset.t(category)}
  def create_category(%Entity{} = entity, attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a category.

  See `create_category/2` docs to know more about the accepted params.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_category(category, map) :: {:ok, category} | {:error, Ecto.Changeset.t(category)}
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
  @spec delete_category(category) :: {:ok, category} | {:error, Ecto.Changeset.t(category)}
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  @spec change_category(category) :: Ecto.Changeset.t(category)
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias Cashtray.Contacts.Contact

  @type contact :: Contact.t()

  @doc """
  Returns the list of contacts.

  You must pass the entity to find the contacts correctely.

  ## Options
    * `:filter` - filters by following attributes:
      * `:type` or `"type"`
      * `:customer` or `"customer"`
      * `:supplier` or `"supplier"`
    * `:search` - search accounts by `:name` or `:legal_name`.
    * See `Cashtray.Paginator.paginate/2` to see paginations options.

  ## Examples

      iex> list_contacts(entity)
      %Cashtray.Paginator{entries: [%Contact{}, ...]}

      iex> list_contacts(entity, filter: %{type: "company"})
      %Cashtray.Paginator{entries: [%Contact{type: "company"}, ...]}

      iex> list_contacts(entity, search: "my")
      %Cashtray.Paginator{entries: [%Contact{name: "My name"}, ...]}

  """
  @spec list_contacts(Entity.t(), keyword) :: Paginator.Page.t(contact)
  def list_contacts(%Entity{} = entity, options \\ []) do
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
  @spec get_contact!(Entity.t(), integer) :: contact
  def get_contact!(%Entity{} = entity, id), do: Repo.get!(Contact, id, prefix: to_prefix(entity))

  @doc """
  Creates a contact.

  You must pass the entity to create the contact correctely.

  ## Params
    * `:name` (required)
    * `:legal_name`
    * `:type` (required) - can be `"company"` or `"person"`, defaults to `"company"`.
    * `:customer` - `boolean`, defaults to false.
    * `:supplier` - `boolean`, defaults to false.
    * `:phone`
    * `:email`

  ## Examples

      iex> create_contact(entity, %{field: value})
      {:ok, %Contact{}}

      iex> create_contact(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_contact(Entity.t(), map) ::
          {:ok, contact} | {:error, Ecto.Changeset.t(contact)}
  def create_contact(%Entity{} = entity, attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a contact.

  See `create_contact/2` docs to know more about the accepted params.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_contact(contact, map) :: {:ok, contact} | {:error, Ecto.Changeset.t(contact)}
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
  @spec delete_contact(contact) :: {:ok, contact} | {:error, Ecto.Changeset.t(contact)}
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  @spec change_contact(contact) :: Ecto.Changeset.t(contact)
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end
end
