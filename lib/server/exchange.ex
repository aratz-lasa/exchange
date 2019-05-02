defmodule Exchange.Exchange do
    use GenServer
    
    def start_link({id, username}=args) do
        GenServer.start_link(__MODULE__, args, name: String.to_atom(id))
    end

    def init({id, username}) do

        {:ok, %{id: id, host: username, host_pid: nil, guests: [], goods: []}}
    end

    def connect_host(id) do
        GenServer.call(id, :connect_host)
    end

    # Callbacks
    def handle_call(:connect_host, from, state) do
        {pid, _tag} = from
        new_state = Map.put(state, :host_pid, pid)
        {:reply, {:ok, "Host connected"}, new_state}
    end

end
