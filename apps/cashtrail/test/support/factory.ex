defmodule Cashtrail.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Cashtrail.Repo

  use Cashtrail.Factory.AccountsFactory
  use Cashtrail.Factory.EntitiesFactory
  use Cashtrail.Factory.CurrenciesFactory
  use Cashtrail.Factory.ContactsFactory
end
