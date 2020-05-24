defmodule Cashtrail.Contacts do
  @moduledoc """
  The Contacts context manages the contact data of one entity.

  See `Cashtrail.Contacts.Contact` to have more info about what contacts mean in
  the application.
  """

  import Ecto.Query, warn: false
  alias Cashtrail.Repo

  alias Cashtrail.{Contacts, Entities, Paginator}

  import Cashtrail.Entities.Tenants, only: [to_prefix: 1, put_prefix: 2]
  import Cashtrail.QueryBuilder, only: [build_filter: 3, build_search: 3]

  @type category :: Contacts.Category.t()

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of contact categories
  in the `:entries` field.

  ## Expected arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the category references.
  * options - A `keyword` list of the following options:
    * `:search` - search categories by its `:description`.
    * See `Cashtrail.Paginator.paginate/2` to know about the pagination options.

  ## Examples

      iex> list_categories(entity)
      %Cashtrail.Paginator{entries: [%Cashtrail.Contacts.Category{}, ...]}

      iex> list_categories(entity, search: "My desc")
      %Cashtrail.Paginator{entries: [%Cashtrail.Contacts.Category{description: "My Description"}, ...]}

  """
  @spec list_categories(Entities.Entity.t(), keyword) :: Paginator.Page.t(category)
  def list_categories(entity, options \\ []) do
    Contacts.Category
    |> build_search(Keyword.get(options, :search), [:description])
    |> put_prefix(entity)
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single contact category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  See `Cashtrail.Contacts.Category` to have more detailed info about the returned
  struct.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the category references.
  * id - A `string` that is the unique id of the category to be found.

  ## Examples

      iex> get_category!(entity, 123)
      %Cashtrail.Contacts.Category{}

      iex> get_category!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_category!(Entities.Entity.t(), Ecto.UUID.t() | String.t()) :: category
  def get_category!(%Entities.Entity{} = entity, id),
    do: Repo.get!(Contacts.Category, id, prefix: to_prefix(entity))

  @doc """
  Creates a contact category.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the category references.
  * params - A `map` with the params of the category to be created:
    * `:description` (required) - A `string` with the description of the category.

  See `Cashtrail.Contacts.Category` to have more detailed info about
  the fields.

  ## Returns

  * `{:ok, %Cashtrail.Contacts.Category{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> create_category(entity, %{field: value})
      {:ok, %Cashtrail.Contacts.Category{}}

      iex> create_category(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_category(Entities.Entity.t(), map) ::
          {:ok, category} | {:error, Ecto.Changeset.t(category)}
  def create_category(%Entities.Entity{} = entity, attrs) do
    %Contacts.Category{}
    |> Contacts.Category.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a contact category.

  ## Expected Arguments

  * category - The `%Cashtrail.Contacts.Category{}` to be updated.
  * params - A `map` with the field of the category to be updated. See
  `create_category/2` to know about the params that can be given.

  ## Returns

  * `{:ok, %Cashtrail.Contacts.Category{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Cashtrail.Contacts.Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_category(category, map) :: {:ok, category} | {:error, Ecto.Changeset.t(category)}
  def update_category(%Contacts.Category{} = category, attrs) do
    category
    |> Contacts.Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact category.

  ## Expected Arguments

  * category - The `%Cashtrail.Contacts.Category{}` to be deleted.

  ## Returns

  * `{:ok, %Cashtrail.Contacts.Category{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> delete_category(category)
      {:ok, %Cashtrail.Contacts.Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_category(category) :: {:ok, category} | {:error, Ecto.Changeset.t(category)}
  def delete_category(%Contacts.Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact category changes.

  ## Expected Arguments

  * category - The `%Cashtrail.Contacts.Category{}` to be tracked.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Cashtrail.Contacts.Category{}}

  """
  @spec change_category(category) :: Ecto.Changeset.t(category)
  def change_category(%Contacts.Category{} = category) do
    Contacts.Category.changeset(category, %{})
  end

  @type contact :: Contacts.Contact.t()

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of contacts in the
  `:entries` field.

  ## Expected arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the contact references.
  * options - A `keyword` list of the following options:
    * `:filter` - filters by following attributes:
      * `:type` or `"type"`
      * `:customer` or `"customer"`
      * `:supplier` or `"supplier"`
      * `:category_id` or `"category_id"`
      * `:search` - search contacts by `:name` or `:legal_name`.
    * See `Cashtrail.Paginator.paginate/2` to know about the pagination options.

  See `Cashtrail.Contacts.Contact` to have more detailed info about the fields to
  be filtered or searched.

  ## Examples

      iex> list_contacts(entity)
      %Cashtrail.Paginator{entries: [%Cashtrail.Contacts.Contact{}, ...]}

      iex> list_contacts(entity, filter: %{type: "company"})
      %Cashtrail.Paginator{entries: [%Cashtrail.Contacts.Contact{type: "company"}, ...]}

      iex> list_contacts(entity, search: "my")
      %Cashtrail.Paginator{entries: [%Cashtrail.Contacts.Contact{name: "My name"}, ...]}

  """
  @spec list_contacts(Entities.Entity.t(), keyword) :: Paginator.Page.t(contact)
  def list_contacts(%Entities.Entity{} = entity, options \\ []) do
    Contacts.Contact
    |> build_filter(Keyword.get(options, :filter), [:type, :customer, :supplier, :category_id])
    |> build_search(Keyword.get(options, :search), [:name, :legal_name])
    |> put_prefix(entity)
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  See `Cashtrail.Contacts.Contact` to have more detailed info about the returned
  struct.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the contact references.
  * id - A `string` that is the unique id of the contact to be found.

  ## Examples

      iex> get_contact!(entity, 123)
      %Cashtrail.Contacts.Contact{}

      iex> get_contact!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_contact!(Entities.Entity.t(), Ecto.UUID.t() | String.t()) :: contact
  def get_contact!(%Entities.Entity{} = entity, id),
    do: Repo.get!(Contacts.Contact, id, prefix: to_prefix(entity))

  @doc """
  Creates a contact.

  ## Expected Arguments

  * entity - The `%Cashtrail.Entities.Entity{}` that the category references.
  * params - A `map` with the params of the contact to be created:
    * `:name` (required) - A `string` with the description of the contact.
    * `:type` (required) - A `string` with the type of contact. It can receive
    "company" or "person". Defaults to `"company"`.
    * `:legal_name` - A `string` that is the legal name of the contact.
    * `:customer` - A `boolean` that says if the contact is a customer. Defaults to false.
    * `:supplier` - A `boolean` that says if the contact is a supplier. Defaults to false.
    * `:phone` - A `string` with the contact phone number. It can receive any phone number format.
    * `:email` - A `string` with the contact email.
    * `:category_id` - A `string` with the id of `Cashtrail.Contacts.Category` that
    relates to the contact.
    * `:address` - A `map` containing the address of the contact:
      * `:street` - A `string` with the street of the contact address.
      * `:number` - A `string` with the number of the contact address.
      * `:complement` - A `string` with the complement of the contact address.
      * `:district` - A `string` with the district of the contact address.
      * `:city` - A `string` with the city of the contact address.
      * `:state` - A `string` with the state or province of the contact address.
      * `:country` - A `string` with the country of the contact address.
      * `:zip` - A `string` with the zip code of the contact address. You can
      insert whatever the zip code of any country you want.
      * `:line_1` - A `string` with line 1 of the contact address, if preferred.
      * `:line_2` - A `string` with line 2 of the contact address, if preferred.

    See `Cashtrail.Contacts.Contact` to have more detailed info about the fields
    of the contact, and `Cashtrail.Contacts.Address` to have more detailed info
    about the field of the address.

  ## Returns

  * `{:ok, %Cashtrail.Contacts.Contact{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> create_contact(entity, %{field: value})
      {:ok, %Cashtrail.Contacts.Contact{}}

      iex> create_contact(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_contact(Entities.Entity.t(), map) ::
          {:ok, contact} | {:error, Ecto.Changeset.t(contact)}
  def create_contact(%Entities.Entity{} = entity, attrs) do
    %Contacts.Contact{}
    |> Contacts.Contact.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a contact.

  ## Expected Arguments

  * category - The `%Cashtrail.Contacts.Category{}` to be updated.
  * params - A `map` with the field of the contact to be updated. See
  `create_contact/2` to know about the params that can be given.

  ## Returns

  * `{:ok, %Cashtrail.Contacts.Contact{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Cashtrail.Contacts.Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_contact(contact, map) :: {:ok, contact} | {:error, Ecto.Changeset.t(contact)}
  def update_contact(%Contacts.Contact{} = contact, attrs) do
    contact
    |> Contacts.Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Expected Arguments

  * contact - The `%Cashtrail.Contacts.Contact{}` to be deleted.

  ## Returns

  * `{:ok, %Cashtrail.Contacts.Contact{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Cashtrail.Contacts.Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_contact(contact) :: {:ok, contact} | {:error, Ecto.Changeset.t(contact)}
  def delete_contact(%Contacts.Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Expected Arguments

  * category - The `%Cashtrail.Contacts.Contact{}` to be tracked.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Cashtrail.Contacts.Contact{}}

  """
  @spec change_contact(contact) :: Ecto.Changeset.t(contact)
  def change_contact(%Contacts.Contact{} = contact) do
    Contacts.Contact.changeset(contact, %{})
  end
end
