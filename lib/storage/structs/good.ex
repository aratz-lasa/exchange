defmodule Good do
    import Record

    defrecord __MODULE__, [:name, :description, :price]
    defstruct [:name, :description, :price]

    def attributes(), do: [:name, :description, :price]
    def to_record(%__MODULE__{name: n, description: d, price: p}), do: {__MODULE__, n, d, p}
    def to_struct({__MODULE__, n, d, p}), do: %__MODULE__{name: n, description: d, price: p}
end