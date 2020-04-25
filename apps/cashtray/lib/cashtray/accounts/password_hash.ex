defmodule Cashtray.Accounts.PasswordHash do
  use Comeonin

  @moduledoc """
  Elixir wrapper for the configured password hashing library in config.exs like
  `config :cashtray, comeonin_hashing_module: Argon2`.
  """

  @hashing_module Application.get_env(:cashtray, :comeonin_hash_module)

  @doc """
  Hashes a password with a randomly generated salt.

  See the documentation for `hash_pwd_salt/2` of your configured hashing libary
  for examples of using this function.
  """
  @impl true
  def hash_pwd_salt(password, opts \\ []),
    do: @hashing_module.hash_pwd_salt(password, opts)

  @doc """
  Verifies a password by hashing the password and comparing the hashed value
  with a stored hash.

  See the documentation for `verify_pass/2` of your configured hashing libary
  for examples of using this function.
  """
  @impl true
  def verify_pass(password, stored_hash),
    do: @hashing_module.verify_pass(password, stored_hash)
end
