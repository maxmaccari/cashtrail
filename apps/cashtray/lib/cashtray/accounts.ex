defmodule Cashtray.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Accounts.{PasswordHash, User}
  alias Cashtray.Paginator

  @type user() :: Cashtray.Accounts.User.t()

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      %Cashtray.Paginator{entries: [%User{}, ...]}

  """
  @spec list_users(keyword) :: Cashtray.Paginator.Page.t()
  def list_users(options \\ []) do
    User
    |> search(Keyword.get(options, :search))
    |> Paginator.paginate(options)
  end

  def search(query, term) when is_binary(term) do
    term = "%#{term}%"

    from(q in query,
      where: ilike(q.first_name, ^term) or ilike(q.last_name, ^term) or ilike(q.email, ^term)
    )
  end

  def search(query, _), do: query

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
  Authenticates a user.

  Returns:
    * {:ok, user} if user is found and the passwords match.
    * {:error, :unauthorized} if passwords does not match.
    * {:error, :not_found} if user email is not found.

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
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map) ::
          {:ok, user()} | {:error, Ecto.Changeset.t(user())}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

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
  Deletes a user.

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
