defmodule Offer do
    import Record

    defrecord __MODULE__, [:good, :price, :offer_id]
    defstruct [:good, :price, :offer_id]
    
    def attributes(), do: [:good, :price, :offer_id]
    def to_record(%__MODULE__{offer_id: o, good: g, price: p}), do: {__MODULE__, o, g, p}
    def to_struct({__MODULE__, o, g, p}), do: %__MODULE__{offer_id: o, good: g, price: p}
end