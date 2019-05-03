defmodule Exchange.Exchange do
    use GenServer
    alias Exchange.User
        
    def start_link({id, username}=args) do
        IO.puts "Registered exchange: #{String.to_atom(id)}"
        GenServer.start_link(__MODULE__, args, name: String.to_atom(id))
    end

    def init({id, username}) do
        {:ok, %{id: id, host: username, host_pid: nil, guests: [], goods: []}}
    end

    def connect_host(id) do
        GenServer.call(id, :connect_host)
    end

    def msg_to_guest({exchange, guest, msg}) do
        GenServer.call(exchange, {:msg_to_guest, guest, msg})
    end

    # Callbacks
    def handle_call(:connect_host, from, state) do
        {pid, _tag} = from
        new_state = Map.put(state, :host_pid, pid)
        {:reply, {:ok, "Host connected"}, new_state}
    end

    def handle_call({:msg_to_guest, guest, msg}, from, state = %{id: id}) do
        response = User.receive_msg(guest, {id, msg})
        {:reply, response, state}
    end
end