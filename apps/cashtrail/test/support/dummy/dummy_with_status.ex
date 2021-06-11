defmodule Cashtrail.DumymWithStatus do
  @derive Cashtrail.Statuses.WithStatus

  defstruct [:archived_at]
end
