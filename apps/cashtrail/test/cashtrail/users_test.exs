defmodule Cashtrail.UsersTest do
  @moduledoc false

  use Cashtrail.DataCase, async: true

  alias Cashtrail.Users

  describe "users" do
    alias Cashtrail.Users.User

    test "list_users/1 returns all users" do
      user = insert(:user)
      assert Users.list_users().entries == [user]
    end

    test "list_users/1 works with pagination" do
      users =
        insert_list(25, :user)
        |> Enum.slice(20, 5)

      assert Users.list_users(page: 2) == %Cashtrail.Paginator.Page{
               entries: users,
               page_number: 2,
               page_size: 20,
               total_entries: 25,
               total_pages: 2
             }
    end

    test "list_users/1 searching by first_name, last_name and email" do
      insert(:user, first_name: "abc", last_name: "def", email: "efg@example.com")
      user = insert(:user, first_name: "ljmn", last_name: "opqr", email: "stuv@example.com")
      assert Users.list_users(search: "jm").entries == [user]
      assert Users.list_users(search: "pq").entries == [user]
      assert Users.list_users(search: "uv@e").entries == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Users.get_user!(user.id) == user
    end

    test "get_user_by/1 returns the user with given param" do
      user = insert(:user)
      assert Users.get_user_by(email: user.email) == user
    end

    test "authenticate_user/2 returns the user with the given id and password" do
      user = insert(:user, password_hash: "my_password123")
      assert {:ok, autenticated} = Users.authenticate(user.email, "my_password123")
      assert autenticated == user
    end

    test "authenticate_user/2 email is case insensitive" do
      user = insert(:user, password_hash: "my_password123")

      assert {:ok, autenticated} = Users.authenticate(String.upcase(user.email), "my_password123")
    end

    test "authenticate_user/2 with invalid password return :unathorized error" do
      user = insert(:user, password_hash: "my_password123")
      assert {:error, :unauthorized} = Users.authenticate(user.email, "invalid")
    end

    test "authenticate_user/2 with invalid email return :not_found error" do
      insert(:user, password_hash: "my_password123")
      assert {:error, :not_found} = Users.authenticate("invalid", "my_password123")
    end

    test "create_user/1 with valid data creates a user" do
      user_params = params_for(:user, password: "@abc1234")
      assert {:ok, %User{} = user} = Users.create_user(user_params)
      assert user.email == user_params.email
      assert user.first_name == user_params.first_name
      assert user.last_name == user_params.last_name
      assert user.avatar_url == user_params.avatar_url
      assert user.password_hash != nil
    end

    test "create_user/1 with uppercase email creates a user with downcased email" do
      user_params = params_for(:user, password: "@abc1234")
      user_params = %{user_params | email: String.upcase(user_params.email)}

      assert {:ok, %User{} = user} = Users.create_user(user_params)

      assert user.email == String.downcase(user_params.email)
    end

    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password: nil, avatar_url: nil}
    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "create_user/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{errors: [email: {"is not a valid email", _}]}} =
               params_for(:user, email: "invalid email", password: "@abc1234")
               |> Users.create_user()
    end

    test "create_user/1 with an already used email returns error changeset" do
      user_params = params_for(:user, password: "@abc1234")

      assert {:ok, %User{} = user} = Users.create_user(user_params)

      assert {:error, %Ecto.Changeset{errors: [email: {"has already been taken", _}]}} =
               Users.create_user(user_params)

      # To ensure that the email validation is case insensitive
      assert {:error, %Ecto.Changeset{errors: [email: {"has already been taken", _}]}} =
               Users.create_user(%{user_params | email: String.upcase(user_params.email)})
    end

    test "create_user/1 with a invalid password returns error changeset" do
      assert {:error,
              %Ecto.Changeset{errors: [password: {"should be at least %{count} character(s)", _}]}} =
               Users.create_user(params_for(:user, password: "@abc123"))

      assert {:error,
              %Ecto.Changeset{errors: [password: {"should be at most %{count} character(s)", _}]}} =
               Users.create_user(params_for(:user, password: "@abc56789012345678901"))

      assert {:error,
              %Ecto.Changeset{
                errors: [
                  password:
                    {"should have at least one special character, one number and one letter", _}
                ]
              }} = Users.create_user(params_for(:user, password: "is invalid"))
    end

    test "create_user/1 with invalid avatar_url returns error changeset" do
      assert {:error, %Ecto.Changeset{errors: [avatar_url: {"is not a valid url", _}]}} =
               params_for(:user, avatar_url: "invalid_url", password: "@abc1234")
               |> Users.create_user()

      assert {:error, %Ecto.Changeset{errors: [avatar_url: {"is not a valid url", _}]}} =
               params_for(:user,
                 avatar_url: "http://maccar'.@example.com/file",
                 password: "@abc1234"
               )
               |> Users.create_user()
    end

    @update_attrs %{
      email: "updated_john_doe@example.com",
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      password: "updated_password123",
      password_confirmation: "updated_password123",
      avatar_url: "http://example.com/image.jpg"
    }
    test "update_user/2 with valid data updates the user" do
      user = %{password_hash: old_password_hash} = insert(:user)
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.email == "updated_john_doe@example.com"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.avatar_url == "http://example.com/image.jpg"
      assert user.password_hash != old_password_hash
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end

    test "change_user/1 downcase the user email" do
      user = build(:user)

      changed_user =
        %{user | email: String.upcase(user.email)}
        |> Users.change_user()
        |> Ecto.Changeset.apply_changes()

      assert changed_user == user
    end
  end
end
