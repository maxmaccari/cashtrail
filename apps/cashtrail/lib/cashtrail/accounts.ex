defmodule Cashtrail.Accounts do
  @moduledoc """
  The Accounts is responsible for deal with user accounts and authentication rules.
  """

  import Ecto.Query, warn: false
  alias Cashtrail.Repo

  alias Cashtrail.Accounts.{PasswordHash, User}
  alias Cashtrail.Paginator

  import Cashtrail.QueryBuilder, only: [build_search: 3]

  @type user() :: Cashtrail.Accounts.User.t()

  @doc """
  Returns the list of users.

  ## Options:
    * `:search` - search accounts by `:first_name`, `:last_name` or `:email`.
    * See `Cashtrail.Paginator.paginate/2` to see the paginations options.

  ## Examples

      iex> list_users()
      %Cashtrail.Paginator{entries: [%User{}, ...]}

      iex> list_users(search: "my")
      %Cashtrail.Paginator{entries: [%User{first_name: "My name"}, ...]}

  """
  @spec list_users(keyword) :: Cashtrail.Paginator.Page.t(user)
  def list_users(options \\ []) do
    User
    |> build_search(Keyword.get(options, :search), [:first_name, :last_name, :email])
    |> Paginator.paginate(options)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(Ecto.UUID.t()) :: user()
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by the given param.

  Returns nil the User does not exist.

  ## Examples

      iex> get_user_by(email: "john@example.com")
      %User{}

      iex> get_user_by(email: "noexists')
      nil

  """
  @spec get_user_by(keyword | map) :: nil | user()
  def get_user_by(params \\ []), do: Repo.get_by(User, params)

  @doc """
  Authenticates an user with its email and password.

  ## Returns
    * `{:ok, user}` if user is found and the passwords match.
    * `{:error, :unauthorized}` if passwords does not match.
    * `{:error, :not_found}` if user email is not found.

  ## Examples

      iex> authenticate(email, password)
      {:ok, %User{}}

      iex> authenticate(email, wrong_pass)
      {:error, :unauthorized}

      iex> authenticate(wrong_email, password)
      {:error, :not_found}
  """
  @spec authenticate(String.t(), String.t()) ::
          {:ok, user()} | {:error, :not_found | :unauthorized}
  def authenticate(email, password) do
    user = get_user_by(email: email)

    cond do
      user && PasswordHash.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        PasswordHash.no_user_verify()
        {:error, :not_found}
    end
  end

  @doc """
  Creates an user.

  ## Params
    * `:email` (required)
    * `:first_name` (required)
    * `:last_name`
    * `:password` (required)
    * `:password_confirmation` (required)

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map) ::
          {:ok, user()} | {:error, Ecto.Changeset.t(user())}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an user.

  See `create_user/1` docs to know more about the accepted params.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(user(), map) :: {:ok, user()} | {:error, Ecto.Changeset.t(user())}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user(user()) :: {:ok, user()} | {:error, Ecto.Changeset.t(user())}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  @spec change_user(user()) :: Ecto.Changeset.t(user())
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
