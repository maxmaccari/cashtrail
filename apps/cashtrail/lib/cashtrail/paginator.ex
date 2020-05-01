defmodule Cashtrail.Paginator do
  alias Cashtrail.Repo
  alias Cashtrail.Paginator.Page

  @moduledoc """
  Allow to fetch paged data with its metadata.
  """

  @doc """
  Returns a `%Cashtrail.Paginator.Page{}` with the entries fetched from a queriable
  and its page metadata.

  The allowed options are:
    * `:page` - the number of page you want to get;
    * `:page_size` - the size of the page you want to get. It can be:
      * `:all` to fetch all entries or;
      * any integer value get the provided count.

  ## Example

      iex> paginate(Entity, page_size: 10)
      %Cashtrail.Paginator.Page{page_size: 10, page: 1, entries: []}

      iex> paginate(Entity, page_size: :all)
      %Cashtrail.Paginator.Page{page_size: 22, page: 1, entries: []}
  """
  @spec paginate(Ecto.Queryable.t(), keyword) :: Page.t()
  def paginate(queriable, options \\ []) do
    queriable
    |> fetch_data(options)
    |> Page.from()
  end

  defp fetch_data(queriable, options) do
    case Keyword.get(options, :page_size, nil) do
      :all -> Repo.all(queriable, options)
      _ -> Repo.paginate(queriable, options)
    end
  end
end