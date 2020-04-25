defmodule Cashtray.FakePasswordHash do
  use Comeonin

  @impl true
  def hash_pwd_salt(password, _opts \\ []) do
    "hashed(#{password})"
  end

  @impl true
  def verify_pass(password, stored_hash) do
    "hashed(#{password})" == stored_hash
  end
end
