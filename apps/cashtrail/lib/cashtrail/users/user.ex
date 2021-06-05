defmodule Cashtrail.Users.User do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a user of the application.

  **Warning**: Don't use the functions of this module. Only use this module as a
  struct to represent a contact. The functions of this module are internal and
  can change over time. Only manipulate contacts through the `Cashtrail.Users`
  that is the context for this.

  The user is any individual that uses the application. They can create their
  entities or be assigned to an entity as a member. See `Cashtrail.Entities.Entity`
  to know more about what is an Entity.

  ## Fields

  * `:id` - The unique id of the user.
  * `:email` - The email address of the user. This must be unique in the whole
  application.
  * `:first_name` - The first name of the user.
  * `:last_name` - The last name of the user.
  * `:password` - This is a virtual field used to the users input their passwords.
  When a user is retrieved, this value is empty.
  * `:password_hash` - This field keeps the hashed password. You can search more
  about hashing algorithms or see `Comeonin` to know more about it.
  * `:inserted_at` - When the user was inserted at the first time.
  * `:updated_at` - When the user was updated at the last time.

  See `Cashtrail.Users` to know how to list, get, insert, update, delete, and
  authenticate users.
  """

  use Ecto.Schema
  import Ecto.Changeset

  import Cashtrail.Users.PasswordHash, only: [hash_pwd_salt: 1]

  @type t :: %Cashtrail.Users.User{
          id: Ecto.UUID.t() | nil,
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          password: String.t() | nil,
          password_hash: String.t() | nil,
          avatar_url: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :avatar_url, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @email_regex ~r/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/
  @password_regex ~r/^(?=.*\d)(?=.*[a-zA-Z]).*/
  @url_regex ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)/

  @spec changeset(t() | Ecto.Changeset.t(t()), map) :: Ecto.Changeset.t(t())
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password, :avatar_url])
    |> validate_required([:first_name, :email, :password])
    |> validate_format(:email, @email_regex, message: "is not a valid email")
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6)
    |> validate_format(:password, @password_regex,
      message: "should have at least one number, and one letter"
    )
    |> validate_format(:avatar_url, @url_regex, message: "is not a valid url")
    |> validate_confirmation(:password)
    |> change_password()
    |> downcase_email()
  end

  defp change_password(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{password: password}, valid?: true} ->
        put_change(changeset, :password_hash, hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  defp downcase_email(changeset) do
    case get_field(changeset, :email) do
      nil -> changeset
      email -> put_change(changeset, :email, String.downcase(email))
    end
  end
end
