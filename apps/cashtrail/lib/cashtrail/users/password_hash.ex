defmodule Cashtrail.Users.PasswordHash do
  use Comeonin

  @moduledoc false

  @hashing_module Application.compile_env(:cashtrail, :comeonin_hash_module, Argon2)

  @doc """
  Generates a random salt and then hashes the password.
  """
  @impl true
  @spec hash_pwd_salt(String.t(), keyword) :: String.t()
  def hash_pwd_salt(password, opts \\ []),
    do: @hashing_module.hash_pwd_salt(password, opts)

  @doc """
  Checks the password by comparing it with a stored hash.

  Please note that the first argument to `verify_pass` should be the
  password, and the second argument should be the password hash.
  """
  @impl true
  @spec verify_pass(String.t(), String.t()) :: boolean
  def verify_pass(password, stored_hash),
    do: @hashing_module.verify_pass(password, stored_hash)
end
