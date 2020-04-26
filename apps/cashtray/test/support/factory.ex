defmodule Cashtray.Factory do
  use ExMachina.Ecto, repo: Cashtray.Repo

  use Cashtray.Factory.AccountsFactory
  use Cashtray.Factory.EntitiesFactory
end
