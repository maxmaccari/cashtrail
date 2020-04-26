defmodule Cashtray.Factory.AccountsFactory do
  alias Cashtray.Accounts.{User, PasswordHash}

  defmacro __using__(_opts) do
    quote do
      alias Cashtray.Factory.AccountsFactory

      def user_factory(attrs \\ %{}) do
        attrs =
          Map.put(attrs, :password_hash, AccountsFactory.put_pass_hash(attrs, "my_password_123"))

        user = %User{
          email: "john_doe@example.com",
          first_name: "some first_name",
          last_name: "some last_name"
        }

        merge_attributes(user, attrs)
      end
    end
  end

  def put_pass_hash(attrs, default) do
    password = Map.get(attrs, :password_hash, default)

    PasswordHash.hash_pwd_salt(password)
  end
end
