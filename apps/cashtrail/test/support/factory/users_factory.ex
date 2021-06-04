defmodule Cashtrail.Factory.UsersFactory do
  @moduledoc false

  alias Cashtrail.Users
  import Cashtrail.Users.PasswordHash, only: [hash_pwd_salt: 1]

  defmacro __using__(_opts) do
    quote do
      alias Cashtrail.Factory.UsersFactory

      def user_factory(attrs \\ %{}) do
        attrs =
          Map.put(attrs, :password_hash, UsersFactory.put_pass_hash(attrs, "my_password_123"))

        user = %Users.User{
          email: Faker.Internet.email(),
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          avatar_url:
            "#{Faker.Internet.image_url()}#{Enum.random([".png", ".jpg", ".jpeg", ".gif", ""])}"
        }

        merge_attributes(user, attrs)
      end
    end
  end

  def put_pass_hash(attrs, default) do
    attrs
    |> Map.get(:password_hash, default)
    |> hash_pwd_salt()
  end
end
