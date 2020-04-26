defmodule Cashtray.Factory.AccountsFactory do
  @moduledoc false

  alias Cashtray.Accounts.{PasswordHash, User}

  defmacro __using__(_opts) do
    quote do
      alias Cashtray.Factory.AccountsFactory

      def user_factory(attrs \\ %{}) do
        attrs =
          Map.put(attrs, :password_hash, AccountsFactory.put_pass_hash(attrs, "my_password_123"))

        user = %User{
          email: Faker.Internet.email(),
          first_name: Faker.Name.first_name(),
          last_name: Faker.Name.last_name()
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
