defmodule Exchange do
    import Record

    defrecord __MODULE__, [:id, :user, :pid]
    defstruct [:id, :user, :pid]

    def attributes(), do: [:id, :user, :pid]
    def to_record(%__MODULE__{id: i, user: u, pid: p}), do: {__MODULE__, i, u, p}
    def to_struct({__MODULE__, i, u, p}), do: %__MODULE__{id: i, user: u, pid: p}
    def to_struct([i, u, p]), do: %__MODULE__{id: i, user: u, pid: p}
end