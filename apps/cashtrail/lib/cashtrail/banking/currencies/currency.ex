defmodule Cashtrail.Banking.Currencies.Currency do
  @moduledoc """
  It represents a currency of banking accounts of the application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtrail.Banking.Currencies.Currency{
          id: Ecto.UUID.t() | nil,
          active: boolean | nil,
          description: String.t() | nil,
          format: String.t() | nil,
          iso_code: String.t() | nil,
          iso_code: String.t() | nil,
          type: String.t() | nil,
          precision: integer | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "currencies" do
    field :active, :boolean, default: true
    field :description, :string
    field :format, :string, default: "0"
    field :iso_code, :string
    field :symbol, :string, default: ""
    field :type, :string, default: "cash"
    field :precision, :integer, default: 0

    timestamps()
  end

  @iso_code_regex ~r/[A-Za-z]{3}/

  @doc false
  @spec changeset(t | Ecto.Changeset.t(t), map) :: Ecto.Changeset.t()
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:description, :iso_code, :symbol, :format, :type, :active, :precision])
    |> validate_required([:description])
    |> validate_inclusion(:type, ["cash", "digital_currency", "miles", "cryptocurrency", "other"])
    |> validate_number(:precision, greater_than_or_equal_to: 0)
    |> validate_length(:iso_code, is: 3)
    |> validate_format(:iso_code, @iso_code_regex, message: "is not a valid ISO 4217 code")
    |> unique_constraint(:iso_code)
    |> upcase_iso_code()
  end

  defp upcase_iso_code(%Ecto.Changeset{changes: %{iso_code: code}} = changeset)
       when is_binary(code) do
    put_change(changeset, :iso_code, String.upcase(code))
  end

  defp upcase_iso_code(changeset), do: changeset
end
