defmodule Cashtray.Accounts.User do
  @moduledoc """
  It represents a user of the application.
  """

  @type t() :: %Cashtray.Accounts.User{
          id: Ecto.UUID.t() | nil,
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          password: String.t() | nil,
          password_hash: String.t() | nil
        }

  use Ecto.Schema
  import Ecto.Changeset

  alias Cashtray.Accounts.PasswordHash
  alias Cashtray.Entities.Entity

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :entities, Entity, foreign_key: :owner_id

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> validate_format(:email, ~r/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/,
      message: "is an invalid email"
    )
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8, max: 20)
    |> validate_format(:password, ~r/^(?=.*\d)(?=.*[a-z])(?=.*[!@#\$%\^&\*\_\=]).*/,
      message: "should have at least one special character, one number and one letter"
    )
    |> validate_confirmation(:password)
    |> change_password()
  end

  defp change_password(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{password: password}, valid?: true} ->
        put_change(changeset, :password_hash, PasswordHash.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
