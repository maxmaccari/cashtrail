defmodule Cashtray.Paginator.Page do
  @moduledoc """
  It's a struct that represents a result of Paginator.paginate
  """

  @type t(type) :: %Cashtray.Paginator.Page{
          entries: list(type),
          page_number: integer,
          page_size: integer,
          total_entries: integer,
          total_pages: integer
        }
  @type t() :: t(any)

  defstruct entries: nil,
            page_number: nil,
            page_size: nil,
            total_entries: nil,
            total_pages: nil

  @doc """
  Convert the returned data to Cashtray.Paginator.Page struct.

  The arguments accepted are %Scrivener.Page{} or list.

  ## Example

    iex> struct = %Scrivener.Page{
    ...>    entries: ["a", "b", "c"],
    ...>    page_number: 1,
    ...>    page_size: 2,
    ...>    total_entries: 3,
    ...>    total_pages: 2
    ...>}
    iex> Cashtray.Paginator.Page.from(struct)
    %Cashtray.Paginator.Page{
      entries: ["a", "b", "c"],
      page_number: 1,
      page_size: 2,
      total_entries: 3,
      total_pages: 2
    }

    iex> list = ["a", "b", "c"]
    iex> Cashtray.Paginator.Page.from(list)
    %Cashtray.Paginator.Page{
      entries: ["a", "b", "c"],
      page_number: 1,
      page_size: 3,
      total_entries: 3,
      total_pages: 1
    }
  """
  @spec from([any] | Scrivener.Page.t()) :: Cashtray.Paginator.Page.t()
  def from(%Scrivener.Page{} = page) do
    %Cashtray.Paginator.Page{
      entries: page.entries,
      page_number: page.page_number,
      page_size: page.page_size,
      total_entries: page.total_entries,
      total_pages: page.total_pages
    }
  end

  def from(entries) when is_list(entries) do
    entries_length = length(entries)

    %Cashtray.Paginator.Page{
      entries: entries,
      page_number: 1,
      page_size: entries_length,
      total_entries: entries_length,
      total_pages: 1
    }
  end
end
