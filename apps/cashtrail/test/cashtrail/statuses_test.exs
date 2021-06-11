defmodule Cashtrail.StatusesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Cashtrail.Statuses
  alias Cashtrail.DumymWithStatus

  test "status/1 return the status defined by WithStatus.status/1 protocol" do
    assert Statuses.status(%DumymWithStatus{}) == :active
    assert Statuses.status(%DumymWithStatus{archived_at: NaiveDateTime.utc_now()}) == :archived
  end

  test "active?/1 returns if the record is active" do
    assert Statuses.active?(%DumymWithStatus{})
    refute Statuses.active?(%DumymWithStatus{archived_at: NaiveDateTime.utc_now()})
  end

  test "archived?/1 returns if the record is archived" do
    assert Statuses.archived?(%DumymWithStatus{archived_at: NaiveDateTime.utc_now()})
    refute Statuses.archived?(%DumymWithStatus{})
  end

  alias Cashtrail.Entities.Entity
  import Ecto.Query

  test "filter_by_status/2 create a query that find the given status" do
    assert Statuses.filter_by_status(Cashtrail.Entities.Entity, %{status: :active}) |> to_sql() ==
             from(e in Entity, where: is_nil(e.archived_at)) |> to_sql()

    assert Statuses.filter_by_status(Cashtrail.Entities.Entity, %{"status" => "active"})
           |> to_sql() ==
             from(e in Entity, where: is_nil(e.archived_at)) |> to_sql()

    assert Statuses.filter_by_status(Cashtrail.Entities.Entity, %{status: :archived}) |> to_sql() ==
             from(e in Entity, where: not is_nil(e.archived_at)) |> to_sql()

    assert Statuses.filter_by_status(Cashtrail.Entities.Entity, %{"status" => "archived"})
           |> to_sql() ==
             from(e in Entity, where: not is_nil(e.archived_at)) |> to_sql()
  end

  test "filter_by_status/2 create a query that find the given statuses" do
    expected_query =
      ~s|SELECT e0."id", e0."name", e0."type", e0."archived_at", e0."owner_id", e0."inserted_at", e0."updated_at" FROM "entities" AS e0 WHERE (NOT (e0."archived_at" IS NULL) OR ((e0."archived_at" IS NULL) OR $1))|

    assert Statuses.filter_by_status(Cashtrail.Entities.Entity, %{status: [:active, :archived]})
           |> to_sql() == expected_query

    assert Statuses.filter_by_status(Cashtrail.Entities.Entity, %{
             "status" => ["active", "archived"]
           })
           |> to_sql() == expected_query
  end

  defp to_sql(query) do
    {sql, _} = Ecto.Adapters.SQL.to_sql(:all, Cashtrail.Repo, query)

    sql
  end
end
