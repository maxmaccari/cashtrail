defmodule Cashtray.Factories.AccountsFactory do
  alias Cashtray.Repo
  alias Cashtray.Accounts.{PasswordHash, User}

  def user_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: "john_doe@example.com",
      first_name: "some first_name",
      last_name: "some last_name",
      password: "my_password_123",
      password_confirmation: "my_password_123"
    })
  end

  def build_user(attrs \\ %{}) do
    User
    |> Repo.load(user_attrs(attrs))
    |> put_pass_hash(attrs)
  end

  @not_loaded_entities %Ecto.Association.NotLoaded{
    __cardinality__: :many,
    __field__: :entities,
    __owner__: User
  }
  def insert_user(attrs \\ %{}) do
    attrs
    |> build_user()
    |> Map.put(:entities, [])
    |> Repo.insert!()
    |> Map.put(:entities, @not_loaded_entities)
  end

  defp put_pass_hash(user, attrs) do
    password = attrs |> user_attrs() |> Map.get(:password)

    %{user | password_hash: PasswordHash.hash_pwd_salt(password)}
  end
end
