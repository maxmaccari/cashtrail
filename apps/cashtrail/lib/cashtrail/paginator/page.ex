defmodule Cashtrail.Paginator.Page do
  @moduledoc false

  @type t(type) :: %Cashtrail.Paginator.Page{
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
  Returns a `%Cashtrail.Paginator.Page{}` with the given data.

  ## Expected arguments

  * page - A `%Scrivener.Page{}` struct or a `list` that should be converted.

  ## Example

    iex> struct = %Scrivener.Page{
    ...>    entries: ["a", "b", "c"],
    ...>    page_number: 1,
    ...>    page_size: 2,
    ...>    total_entries: 3,
    ...>    total_pages: 2
    ...>}
    iex> Cashtrail.Paginator.Page.from(struct)
    %Cashtrail.Paginator.Page{
      entries: ["a", "b", "c"],
      page_number: 1,
      page_size: 2,
      total_entries: 3,
      total_pages: 2
    }

    iex> list = ["a", "b", "c"]
    iex> Cashtrail.Paginator.Page.from(list)
    %Cashtrail.Paginator.Page{
      entries: ["a", "b", "c"],
      page_number: 1,
      page_size: 3,
      total_entries: 3,
      total_pages: 1
    }
  """
  @spec from([any] | Scrivener.Page.t()) :: Cashtrail.Paginator.Page.t()
  def from(%Scrivener.Page{
        entries: entries,
        page_number: page_number,
        page_size: page_size,
        total_entries: total_entries,
        total_pages: total_pages
      }) do
    %Cashtrail.Paginator.Page{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  def from(entries) when is_list(entries) do
    entries_length = length(entries)

    %Cashtrail.Paginator.Page{
      entries: entries,
      page_number: 1,
      page_size: entries_length,
      total_entries: entries_length,
      total_pages: 1
    }
  end
end
