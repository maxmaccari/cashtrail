defmodule Cashtray.AccountsTest do
  use Cashtray.DataCase

  alias Cashtray.Accounts

  describe "users" do
    alias Cashtray.Accounts.User

    @valid_attrs %{
      email: "john_doe@example.com",
      first_name: "some first_name",
      last_name: "some last_name",
      password: "my_password",
      password_confirmation: "my_password"
    }
    @update_attrs %{
      email: "updated_john_doe@example.com",
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      password: "updated password",
      password_confirmation: "updated password"
    }
    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      %{user | password: nil}
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "authenticate_user/2 returns the user with the given id and password" do
      user = user_fixture()
      assert {:ok, autenticated} = Accounts.authenticate("john_doe@example.com", "my_password")
      assert autenticated == user
    end

    test "authenticate_user/2 with invalid password return :unathorized error" do
      user_fixture()
      assert {:error, :unauthorized} = Accounts.authenticate("john_doe@example.com", "invalid")
    end

    test "authenticate_user/2 with invalid email return :not_found error" do
      user_fixture()
      assert {:error, :not_found} = Accounts.authenticate("invalid@example.com", "my_password")
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "john_doe@example.com"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{errors: [email: {"is an invalid email", _}]}} =
               Accounts.create_user(%{@valid_attrs | email: "invalid_email"})
    end

    test "update_user/2 with valid data updates the user" do
      user = %{password_hash: old_password_hash} = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "updated_john_doe@example.com"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.password_hash != old_password_hash
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
