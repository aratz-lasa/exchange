defmodule Exchange.Exchange do
    use GenServer
    alias Exchange.User
    alias Exchange.Protocol, as: Prot
    import Exchange.Server.Utils
        
    def start_link({id, host}=args) do
        args = {String.to_atom(id), String.to_atom(host)}
        GenServer.start_link(__MODULE__, args, name: String.to_atom(id))
    end

    def init({id, host}) do
        {:ok, %{id: id, host: host, ids_guests: %{}, guests_ids: %{}, goods: [], banned: MapSet.new()}}
    end

    # Host API
    def connect_host(id, host) do
        GenServer.call(id, {:connect_host, String.to_atom(host)})
    end

    def msg_to_guest({exchange, guest_id, msg}) do
        GenServer.call(exchange, {:msg_to_guest, guest_id, msg})
    end

    # Guest API
    def connect_guest(exchange, guest) do
        GenServer.call(exchange, {:connect_guest, String.to_atom(guest)})
    end

    # Callbacks
    def handle_call({:connect_host, host}, _from, state) do
        new_state = Map.put(state, :host, host)
        reply_ok("Host connected", new_state)
    end

    def handle_call({:msg_to_guest, guest_id, msg}, _from, state = %{id: id, ids_guests: ids_guests}) do
        guest = Map.get(ids_guests, guest_id)
        if guest != nil do
            response = {:ok, Enum.join([id, msg], "#")}
            User.receive_msg(guest, {response, Prot.rcv_from_host})
             |> reply(state)
        else
           reply_error("Invalid guest", state) 
        end
    end

    def handle_call({:connect_guest, guest}, _from, %{id: id, host: host}=state) do
        if check_banned(guest, state) do
          reply_error("Banned guest", state)
        else
            guest_id = Randomizer.generate!(20)
            new_guests_ids = Map.get(state, :guests_ids)
                          |> Map.put(guest, guest_id)
            new_ids_guests = Map.get(state, :ids_guests)
                            |> Map.put(guest_id, guest)
            new_state = Map.put(state, :guests_ids, new_guests_ids) 
                         |> Map.put(:ids_guests, new_ids_guests)
            msg = {:ok, Enum.join([id, guest_id], "#")}
            IO.puts "Sent Notification to Host: #{host}"
            User.receive_msg(host, {msg, Prot.guest_connected})
            reply_ok(guest_id, new_state)
        end
    end
end
