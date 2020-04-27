defmodule Cashtray.Currencies.Currency do
  @moduledoc """
  It represents a currency of accounts of the application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtray.Currencies.Currency{
          id: Ecto.UUID.t() | nil,
          active: boolean | nil,
          description: String.t() | nil,
          format: String.t() | nil,
          iso_code: String.t() | nil,
          iso_code: String.t() | nil,
          type: String.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "currencies" do
    field :active, :boolean, default: true
    field :description, :string
    field :format, :string, default: "#0.00"
    field :iso_code, :string
    field :symbol, :string, default: ""
    field :type, :string, default: "cash"

    timestamps()
  end

  @doc false
  @spec changeset(t | Ecto.Changeset.t(t), map) :: Ecto.Changeset.t()
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:description, :iso_code, :symbol, :format, :type, :active])
    |> validate_required([:description])
    |> validate_inclusion(:type, ["cash", "digital_currency", "miles", "cryptocurrency", "other"])
  end
end
