defmodule Exchange.Exchange do
    use GenServer
    
    def start_link(args) do
        GenServer.start_link(__MODULE__, args)
    end

    def init({id, user}) do
        {:ok, %Exchange{id: id, user: user}}
    end

end