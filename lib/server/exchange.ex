defmodule Exchange do
    use GenServer

    # server's API
    def start(host_pid, xch_id) when is_pid(host_pid) do
      GenServer.start(__MODULE__, {host_pid, xch_id})
    end

    # host's API
    def add_good(pid, good) do
        GenServer.call(pid, {:add_good, good})
    end

    def msg_to_guest(pid, guest, msg) do
        GenServer.cast(pid, {:msg_to_guest, guest, msg})
    end

    # guests' API
    def join_exchange(pid) do
        GenServer.call(pid, :join_xch)
    end

    def msg_to_host(pid, guest, msg) do
        GenServer.cast(pid, {:msg_to_host, guest, msg})
    end


    # callbacks
    @impl true
    def init({host_pid, xch_id}) when is_pid(host_pid) and is_bitstring(xch_id) do
        xch_info = %{:xch_id=>xch_id, :host=>host_pid, :guests=> [], :goods=>[]}
        {:ok, xch_info}
    end

    @impl true
    def handle_call({:add_good, good}, _from, xch_info) do
        new_goods =  [good | Map.get(xch_info, :goods)]
        xch_info = Map.replace!(xch_info, :goods, new_goods)
        {:reply, :ok, xch_info}
    end

    @impl true
    def handle_call(:join_xch, from, xch_info) do
        {guest, _} = from
        new_guests =  [guest | Map.get(xch_info, :guests)]
        xch_info = Map.replace!(xch_info, :guests, new_guests)
        {:reply, :ok, xch_info}
    end

    @impl true
    def handle_cast({:msg_to_guest, guest, msg}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        send(guest, {xch_id, msg})
        {:noreply, xch_info}
    end
    
    @impl true
    def handle_cast({:msg_to_host, guest, msg}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        Map.get(xch_info, :host) |> send({xch_id, guest, msg})
        {:noreply, xch_info}
    end

end