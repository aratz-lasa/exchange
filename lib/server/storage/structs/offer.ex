defmodule Offer do
  import Record

  defrecord __MODULE__, [:id, :good, :price, :amount]
  defstruct [:id, :good, :price, :amount]

  def attributes(), do: [:id, :good, :price, :amount]

  def to_record(%__MODULE__{id: i, good: g, price: p, amount: a}),
    do: {__MODULE__, i, g, p, a}

  def to_struct({__MODULE__, i, g, p, a}),
    do: %__MODULE__{id: i, good: g, price: p, amount: a}

  def to_struct([i, g, p, a]), do: %__MODULE__{id: i, good: g, price: p, amount: a}

  def encode(%__MODULE__{id: i, good: g, price: p, amount: a}),
    do: Enum.join([i, g, p, a], "#")

  def decode(data) when is_binary(data), do: to_struct(String.split(data, "#", parts: 4))
end
