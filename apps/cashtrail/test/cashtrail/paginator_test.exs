defmodule Cashtrail.PaginatorTest do
  @moduledoc false

  use Cashtrail.DataCase, async: true

  alias Cashtrail.Entities.Entity
  alias Cashtrail.Paginator

  test "paginate/2 with default params returns 20 registers from database" do
    entries = insert_list(35, :entity) |> Enum.map(&forget(&1, :owner)) |> Enum.take(20)

    assert Paginator.paginate(Entity) == %Cashtrail.Paginator.Page{
             page_number: 1,
             page_size: 20,
             total_pages: 2,
             total_entries: 35,
             entries: entries
           }
  end

  test "paginate/2 with page_size: :all returns all registers from database" do
    entries = insert_list(35, :entity) |> Enum.map(&forget(&1, :owner))

    assert Paginator.paginate(Entity, page_size: :all) == %Cashtrail.Paginator.Page{
             page_number: 1,
             page_size: 35,
             total_pages: 1,
             total_entries: 35,
             entries: entries
           }
  end

  test "paginate/2 with page_size: 10 returns registers paginated by 10" do
    entries = insert_list(30, :entity) |> Enum.map(&forget(&1, :owner)) |> Enum.take(10)

    assert Paginator.paginate(Entity, page_size: 10) == %Cashtrail.Paginator.Page{
             page_number: 1,
             page_size: 10,
             total_pages: 3,
             total_entries: 30,
             entries: entries
           }
  end

  test "paginate/2 with page: 2 returns registers paginated by 20 in page 2" do
    entries = insert_list(30, :entity) |> Enum.map(&forget(&1, :owner)) |> Enum.slice(20, 10)

    assert Paginator.paginate(Entity, page: 2) == %Cashtrail.Paginator.Page{
             page_number: 2,
             page_size: 20,
             total_pages: 2,
             total_entries: 30,
             entries: entries
           }
  end
end