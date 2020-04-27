defmodule Cashtray.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Cashtray.Repo

  use Cashtray.Factory.AccountsFactory
  use Cashtray.Factory.EntitiesFactory
  use Cashtray.Factory.CurrenciesFactory
end
