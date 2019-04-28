defmodule Exchange.Exchange do
    use GenServer
    
    def init({id, user}) do
        {:ok, %{id: id, user: user}}
    end

end