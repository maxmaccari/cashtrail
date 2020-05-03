defmodule Cashtrail.Users do
  @moduledoc """
  The Users context manages the users data of one entity and perform users
  authentication.

  See `Cashtrail.Users.User` to have more info about user.
  """

  import Ecto.Query, warn: false
  alias Cashtrail.Repo

  alias Cashtrail.Users.{PasswordHash, User}
  alias Cashtrail.Paginator

  import Cashtrail.QueryBuilder, only: [build_search: 3]

  @type user() :: User.t()

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` struct with a list of users in the
  `:entries` field.

  ## Expected arguments

  * options - A `keyword` list of the following options:
    * `:search` - search users by `:first_name`, `:last_name` or `:email`.
    * See `Cashtrail.Paginator.paginate/2` to see the paginations options.

  See `Cashtrail.Users.User` to have more detailed info about the fields to
  be filtered or searched.

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

  See `Cashtrail.Users.User` to have more detailed info about the returned
  struct.

  ## Expected Arguments

  * id - A `string` that is the unique id of the user to be found.


  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(Ecto.UUID.t() | String.t()) :: user()
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by the given param.

  Returns nil the User does not exist.

  See `Cashtrail.Users.User` to have more detailed info about the returned
  struct and about the params attributes that can be given.

  ## Expected Arguments

  * params - A `keyword` or a `map` with the attributes of the user to be found.

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

  ## Expected Arguments

  * email - A `string` that is the email of the user.
  * password - A `string` that is the expected password of the user.

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

  ## Expected Arguments

  * params - A `map` with the params of the user to be created:
    * `:email` (required) - A `string` with the email of the user. Must be
    a valid email and unique in the application.
    * `:first_name` (required) - A `string` with first name of the user.
    * `:last_name` - A `string` with first last of the user.
    * `:password` (required) - A `string` with the password of the user to be created.
    The password must contain at least one letter, one number and one special character.
    * `:password_confirmation` (required) - A `string` with password confirmation
    of the user to be created. Must be the equals the `:password` field.

  See `Cashtrail.Users.User` to have more detailed info about the fields.

  ## Returns

  * `{:ok, %Cashtrail.Users.User{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

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

  ## Expected Arguments

  * user - The `%Cashtrail.Users.User{}` to be updated.
  * params - A `map` with the field of the user to be updated. See
  `create_user/2` to know about the params that can be given.

  ## Returns

  * `{:ok, %Cashtrail.Users.User{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

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

  ## Expected Arguments

  * user - The `%Cashtrail.Users.User{}` to be deleted.

  ## Returns

  * `{:ok, %Cashtrail.Users.User{}}` in case of success.
  * `{:error, %Ecto.Changeset{}}` in case of error.

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

  ## Expected Arguments

  * user - The `%Cashtrail.Users.User{}` to be tracked.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  @spec change_user(user()) :: Ecto.Changeset.t(user())
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
