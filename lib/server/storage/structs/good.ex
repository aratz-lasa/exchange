defmodule Good do
  import Record

  defrecord __MODULE__, [:id, :name, :price, :description]
  defstruct [:id, :name, :price, :description]

  def attributes(), do: [:id, :name, :price, :description]
  def to_record(%__MODULE__{id: i, name: n, price: p, description: d}), do: {__MODULE__, i, n, p, d}
  def to_struct({__MODULE__, i, n, p, d}), do: %__MODULE__{id: i, name: n, price: p, description: d}
  def to_struct([i, n, p, d]), do: %__MODULE__{id: i, name: n, price: p, description: d}
  def encode(%__MODULE__{id: i, name: n, price: p, description: d}), do: Enum.join([i, n, p, d], "#")
  def decode(data) when is_binary(data), do: to_struct String.split(data, "#", parts: 4)
end
