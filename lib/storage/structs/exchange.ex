defmodule Exchange do
    import Record

    defrecord __MODULE__, [:id, :user]
    defstruct [:id, :user]

    def attributes(), do: [:id, :user]
    def to_record(%__MODULE__{id: i, user: u}), do: {__MODULE__, i, u}
    def to_struct({__MODULE__, i, u}), do: %__MODULE__{id: i, user: u}
    def to_struct([i, u]), do: %__MODULE__{id: i, user: u}
end