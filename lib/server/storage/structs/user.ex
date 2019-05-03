defmodule User do
    import Record

    defrecord __MODULE__, [:username, :password]
    defstruct [:username, :password]
    
    def attributes(), do: [:username, :password]
    def to_record(%__MODULE__{username: u, password: p}), do: {__MODULE__, u, p}
    def to_struct({__MODULE__, u, p}), do: %__MODULE__{username: u, password: p}
    def to_struct([u, p]), do: %__MODULE__{username: u, password: p}
end