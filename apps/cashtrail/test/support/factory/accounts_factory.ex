defmodule Cashtrail.Factory.UsersFactory do
  @moduledoc false

  alias Cashtrail.Users.{PasswordHash, User}

  defmacro __using__(_opts) do
    quote do
      alias Cashtrail.Factory.UsersFactory

      def user_factory(attrs \\ %{}) do
        attrs =
          Map.put(attrs, :password_hash, UsersFactory.put_pass_hash(attrs, "my_password_123"))

        user = %User{
          email: Faker.Internet.email(),
          first_name: Faker.Name.first_name(),
          last_name: Faker.Name.last_name(),
          avatar_url:
            "#{Faker.Internet.image_url()}#{Enum.random([".png", ".jpg", ".jpeg", ".gif", ""])}"
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
