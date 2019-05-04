defmodule Exchange.Exchange do
    use GenServer
    alias Exchange.User
        
    def start_link({id, _username}=args) do
        GenServer.start_link(__MODULE__, args, name: String.to_atom(id))
    end

    def init({id, username}) do
        {:ok, %{id: id, host: username, ids_guests: %{}, guests_ids: %{}, goods: [], banned: MapSet.new()}}
    end

    # Host API
    def connect_host(id, host_name) do
        GenServer.call(id, {:connect_host, host_name})
    end

    def msg_to_guest({exchange, guest_id, msg}) do
        GenServer.call(exchange, {:msg_to_guest, guest_id, msg})
    end

    # Guest API
    def connect_guest(exchange, guest_name) do
        GenServer.call(exchange, {:connect_guest, guest_name})
    end

    # Callbacks
    def handle_call({:connect_host, host_name}, _from, state) do
        new_state = Map.put(state, :host, host_name)
        reply_ok("Host connected", new_state)
    end

    def handle_call({:msg_to_guest, guest_id, msg}, _from, state = %{id: id, ids_guests: ids_guests}) do
        guest = Map.get(ids_guests, guest_id)
        if guest != nil do
            User.receive_msg(guest, {id, msg})
             |> reply(state)
        else
           reply_error("Invalid guest", state) 
        end
    end

    def handle_call({:connect_guest, guest}, _from, state) do
        if check_banned(guest, state) do
          reply_error("Banned guest", state)
        else
            id = Randomizer.generate!(20)
            new_guests_ids = Map.get(state, :guests_ids)
                          |> Map.put(guest, id)
            new_ids_guests = Map.get(state, :ids_guests)
                            |> Map.put(id, guest)
            new_state = Map.put(state, :guests_ids, new_guests_ids) 
                         |> Map.put(:ids_guests, new_ids_guests)
            reply_ok(id, new_state)
        end
    end

    # Utils

    def check_banned(guest, state) do
        state
         |> Map.get(:banned)
         |> MapSet.member?(guest)
    end

    def reply_error(response, state) do
        reply({:error, response}, state)
    end

    def reply_ok(response, state) do
        reply({:ok, response}, state)
    end

    def reply(response, state) do
        {:reply, response, state}
    end
end
