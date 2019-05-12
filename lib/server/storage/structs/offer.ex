defmodule Offer do
  import Record

  defrecord __MODULE__, [:offer_id, :good, :price, :amount]
  defstruct [:offer_id, :good, :price, :amount]

  def attributes(), do: [:offer_id, :good, :price, :amount]

  def to_record(%__MODULE__{offer_id: o, good: g, price: p, amount: a}),
    do: {__MODULE__, o, g, p, a}

  def to_struct({__MODULE__, o, g, p, a}),
    do: %__MODULE__{offer_id: o, good: g, price: p, amount: a}

  def to_struct([o, g, p, a]), do: %__MODULE__{offer_id: o, good: g, price: p, amount: a}

  def encode(%__MODULE__{offer_id: o, good: g, price: p, amount: a}),
    do: Enum.join([o, g, p, a], "#")

  def decode(data) when is_binary(data), do: to_struct(String.split(data, "#", parts: 4))
end
