defmodule Cashtrail.DumymWithStatus do
  @moduledoc false

  @derive Cashtrail.Statuses.WithStatus

  defstruct [:archived_at]
end
