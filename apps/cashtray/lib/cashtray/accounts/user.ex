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
          password_hash: String.t() | nil,
          avatar_url: String.t() | nil,
          entities: Ecto.Association.NotLoaded.t() | list(Cashtray.Entities.Entity.t()),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
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
    field :avatar_url, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :entities, Entity, foreign_key: :owner_id

    timestamps()
  end

  @email_regex ~r/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/
  @password_regex ~r/^(?=.*\d)(?=.*[a-z])(?=.*[!@#\$%\^&\*\_\=]).*/
  @url_regex ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)/

  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password, :avatar_url])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> validate_format(:email, @email_regex, message: "is not a valid email")
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8, max: 20)
    |> validate_format(:password, @password_regex,
      message: "should have at least one special character, one number and one letter"
    )
    |> validate_format(:avatar_url, @url_regex, message: "is not a valid url")
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
