defmodule Cashtray.Currencies do
  @moduledoc """
  The Currencies context.
  """

  @type currency :: Cashtray.Currencies.Currency.t()

  import Ecto.Query, warn: false
  alias Cashtray.Repo

  alias Cashtray.Currencies.Currency
  alias Cashtray.Entities.Entity

  import Cashtray.Entities.Tenants, only: [to_prefix: 1]

  @doc """
  Returns the list of currencies.

  You must pass the entity to find the currency correctely.

  ## Examples

      iex> list_currencies(entity)
      [%Currency{}, ...]

  """
  @spec list_currencies(Cashtray.Entities.Entity.t()) :: list(currency)
  def list_currencies(%Entity{} = entity) do
    Repo.all(Currency, prefix: to_prefix(entity))
  end

  @doc """
  Gets a single currency.

  You must pass the entity to find the currency correctely.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  ## Examples

      iex> get_currency!(entity, 123)
      %Currency{}

      iex> get_currency!(entity, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_currency!(Cashtray.Entities.Entity.t(), integer) :: currency
  def get_currency!(%Entity{} = entity, id) do
    Repo.get!(Currency, id, prefix: to_prefix(entity))
  end

  @doc """
  Creates a currency.

  You must pass the entity to create the currency correctely.

  ## Examples

      iex> create_currency(entity, %{field: value})
      {:ok, %Currency{}}

      iex> create_currency(entity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_currency(Cashtray.Entities.Entity.t(), map) ::
          {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def create_currency(%Entity{} = entity, attrs \\ %{}) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert(prefix: to_prefix(entity))
  end

  @doc """
  Updates a currency.

  ## Examples

      iex> update_currency(currency, %{field: new_value})
      {:ok, %Currency{}}

      iex> update_currency(currency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_currency(currency, map) :: {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def update_currency(%Currency{} = currency, attrs) do
    currency
    |> Currency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a currency.

  ## Examples

      iex> delete_currency(currency)
      {:ok, %Currency{}}

      iex> delete_currency(currency)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_currency(currency) :: {:ok, currency} | {:error, Ecto.Changeset.t(currency)}
  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking currency changes.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{source: %Currency{}}

  """
  @spec change_currency(currency) :: Ecto.Changeset.t(currency)
  def change_currency(%Currency{} = currency) do
    Currency.changeset(currency, %{})
  end
end
