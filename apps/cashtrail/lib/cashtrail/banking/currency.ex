defmodule Cashtrail.Banking.Currency do
  @moduledoc """
  This is an `Ecto.Schema` struct that represents a currency of the entity.

  **Warning**: Don't use the functions of this module. Only use this module as a
  struct to represent a currency. The functions of this module are internal and
  can change over time. Only manipulate currencies through the `Cashtrail.Banking`
  that is the context for this.

  ## Definition

  According to [Investopedia](https://www.investopedia.com/terms/c/currency.asp),
  the currency is any form when in use or circulation as a medium of exchange. This
  can be any system of money in common use by people.

  The common examples of currencies are Brazilia, reais (R$), U.S. dollars (US$),
  euros (€), Japanese yen (¥), and pounds sterling (£). There are cryptocurrencies
  too. In this application, you don't have to be stuck with that definition. You
  can register any means of exchange you use as a currency. It could be your airline
  miles, some other kind of currency that you use in any community.

  Anything you want to track can be registered as a currency. Just know that a
  bank account can only have one currency registered. And all transactions will
  be performed in that currency. The only way to convert a currency to another
  is through a special form of transaction called 'exchange'. So you can use
  this to track your expenses in another currency on one travel or track your
  miles usage.

  Each entity will have their currencies, then you can register or delete
  currencies without worries. So you are free to define how you will use this
  feature.

  ## Fields

  * `:id` - The unique id of the currency.
  * `:description` - The description of the currency.
  * `:type` - The type of currency. Can be:
    * `"money"` - ordinary currencies like dollars, euro, yen, etc. This is the
    default value if no type is chosen.
    * `"cryptocurrency"` - digital currencies that use cryptographical functions
    to conduct financial transactions.
    * `"virtual"` - unregulated digital currencies, used and accepted
    among the members of a specific virtual community. For example loyalty points, game points, etc.
    * `"other"` - other types of currencies that don't match the previous categories.
  * `:iso_code` - The [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217) code of the currency.
  * `:active` - Says if the currency is active or not. This field can be used only
  to hide the currency in currencies listing. This doesn't archive accounts that use
  this currency, and not prevents the currency using.
  * `:symbol` -  The symbol of the currency, like R$, US$, €, ¥, or £ for example.
  * `:precision` - Every currency can have a different number of decimal places.
  For example, the dinar has three decimal places, dollar two, and yen zero.
  This field can be used to help round and format the amounts for the currency
  correctly.
  * `:separator` - The field can be used to separate the integer part from the fractional
  part of the currency.
  * `:delimiter` - The field can be used to separate the thousands parts of the currency.
  * `:format` - This field can be used to know in what format the symbol and the number
  should be displayed. The "%s" represents the symbol, and the "%n" represents the
  number. So, if you format 100 dollars using `"%s %n"` the expected format will
  be `"US$ 100.00"`. This field, as the `:precision`, `:separator` and `:delimiter`,
  only brings a reference to be used by the libraries that will perform the
  currency formating.
  * `:inserted_at` - When the currency was inserted at the first time.
  * `:updated_at` - When the currency was updated at the last time.

  See `Cashtrail.Banking` to know how to list, get, insert, update, and delete currencies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %Cashtrail.Banking.Currency{
          id: Ecto.UUID.t() | nil,
          description: String.t() | nil,
          iso_code: String.t() | nil,
          type: String.t() | nil,
          active: boolean | nil,
          symbol: String.t() | nil,
          precision: integer() | nil,
          separator: String.t() | nil,
          delimiter: String.t() | nil,
          format: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          __meta__: Ecto.Schema.Metadata.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "currencies" do
    field :description, :string
    field :iso_code, :string
    field :type, :string, default: "money"
    field :active, :boolean, default: true
    field :symbol, :string, default: ""
    field :precision, :integer, default: 0
    field :separator, :string, default: "."
    field :delimiter, :string, default: ""
    field :format, :string, default: "%s%n"

    timestamps()
  end

  @iso_code_regex ~r/[A-Za-z]{3}/

  @doc false
  @spec changeset(t | Ecto.Changeset.t(t), map) :: Ecto.Changeset.t()
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [
      :description,
      :iso_code,
      :symbol,
      :format,
      :type,
      :active,
      :precision,
      :separator,
      :delimiter
    ])
    |> validate_required([:description])
    |> validate_inclusion(:type, ["money", "cryptocurrency", "digital", "virtual", "other"])
    |> validate_length(:iso_code, is: 3)
    |> validate_format(:iso_code, @iso_code_regex, message: "is not a valid ISO 4217 code")
    |> unique_constraint(:iso_code)
    |> validate_number(:precision, greater_than_or_equal_to: 0)
    |> validate_length(:separator, is: 1)
    |> validate_length(:delimiter, min: 0, max: 1)
    |> validate_format()
    |> upcase_iso_code()
  end

  defp upcase_iso_code(%Ecto.Changeset{changes: %{iso_code: code}} = changeset)
       when is_binary(code) do
    put_change(changeset, :iso_code, String.upcase(code))
  end

  defp upcase_iso_code(changeset), do: changeset

  defp validate_format(%Ecto.Changeset{changes: %{format: format}} = changeset)
       when is_binary(format) do
    if String.contains?(format, "%n") do
      changeset
    else
      add_error(changeset, :format, "Should have one %n to display the number, or be empty")
    end
  end

  defp validate_format(changeset), do: changeset
end
