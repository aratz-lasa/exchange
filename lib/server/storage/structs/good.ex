defmodule Good do
  import Record

  defrecord __MODULE__, [:name, :price, :description]
  defstruct [:name, :price, :description]

  def attributes(), do: [:name, :price, :description]
  def to_record(%__MODULE__{name: n, price: p, description: d}), do: {__MODULE__, n, p, d}
  def to_struct({__MODULE__, n, p, d}), do: %__MODULE__{name: n, price: p, description: d}
  def to_struct([n, p, d]), do: %__MODULE__{name: n, price: p, description: d}
  def encode(%__MODULE__{name: n, price: p, description: d}), do: Enum.join([n, p, d], "#")
end
