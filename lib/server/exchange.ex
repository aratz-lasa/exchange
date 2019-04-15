defmodule Exchange do
    use GenServer

    ## API
    # server
    def add_xch_id(pid, xch_id) do
       :ok = GenServer.call(pid, {:add_xch_id, xch_id})
    end   

    # host
    def start_link(host_pid) when is_pid(host_pid) do
        GenServer.start_link(__MODULE__, host_pid)
      end

    def connect_host(pid) do
        :ok = GenServer.call(pid, :connect_host)
    end

    def disconnect_host(pid) do
        :ok = GenServer.cast(pid, :disconnect_host)
    end

    def add_good(pid, good) do
        :ok = GenServer.call(pid, {:add_good, good})
    end

    def msg_to_guest(pid, guest, msg) do
        GenServer.cast(pid, {:msg_to_guest, guest, msg})
    end

    def accept_offer(pid, guest, offer_id) do
        GenServer.cast(pid, {:accept_offer, guest, offer_id})
    end

    def decline_offer(pid, guest, offer_id) do
        GenServer.cast(pid, {:decline_offer, guest, offer_id})
    end

    # guest
    def join_guest(pid) do
        :ok = GenServer.call(pid, :join_guest)
    end

    def leave_guest(pid, guest) do
        :ok = GenServer.cast(pid, {:leave_guest, guest})
    end

    def get_goods(pid) do
        :ok = GenServer.call(pid, :get_goods)
    end

    def msg_to_host(pid, guest, msg) do
        GenServer.cast(pid, {:msg_to_host, guest, msg})
    end

    def send_offer(pid, guest, offer) do
        GenServer.cast(pid, {:send_offer, guest, offer})
    end

    ## callbacks
    @impl true
    def init(host_pid) when is_pid(host_pid) do
        xch_info = %{:host_connected=>true, :xch_id=>nil, :host=>host_pid, :guests=> [], :goods=>[]}
        {:ok, xch_info}
    end

    # synchronous calls
    @impl true
    def handle_call({:add_xch_id, xch_id}, _from, xch_info) do
        xch_info =  Map.replace!(xch_info, :xch_id, xch_id)
        {:reply, :ok, xch_info}
    end

    @impl true
    def handle_call(:connect_host, _from, xch_info) do
        xch_info =  Map.replace!(xch_info, :host_connected, true)
        {:reply, :ok, xch_info}
    end

    @impl true
    def handle_call({:add_good, good}, _from, xch_info) do
        new_goods =  [good | Map.get(xch_info, :goods)]
        xch_info = Map.replace!(xch_info, :goods, new_goods)
        {:reply, :ok, xch_info}
    end

    @impl true
    def handle_call(:join_guest, from, xch_info) do
        {guest, _} = from
        new_guests =  [guest | Map.get(xch_info, :guests)]
        xch_info = Map.replace!(xch_info, :guests, new_guests)
        {:reply, :ok, xch_info}
    end

    @impl true
    def handle_call(:get_goods, _from, xch_info) do
        {:reply, {:ok, Map.get(xch_info, :goods)}, xch_info}
    end

    # asynchronous calls
    @impl true
    def handle_cast(:disconnect_host, xch_info) do
        xch_info =  Map.replace!(xch_info, :host_connected, false)
        {:reply, :ok, xch_info}
    end
    
    @impl true
    def handle_cast({:msg_to_guest, guest, msg}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        send(guest, {xch_id, msg})
        {:noreply, xch_info}
    end

    @impl true
    def handle_cast({:accept_offer, guest, offer_id}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        guest |> send({xch_id, offer_id, :accept})
        {:noreply, xch_info}
    end

    @impl true
    def handle_cast({:decline_offer, guest, offer_id}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        guest |> send({xch_id, offer_id, :decline})
        {:noreply, xch_info}
    end

    @impl true
    def handle_cast({:msg_to_host, guest, msg}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        Map.get(xch_info, :host) |> send({xch_id, guest, msg})
        {:noreply, xch_info}
    end

    @impl true
    def handle_cast({:leave_guest, guest}, xch_info) do
        new_guests = Map.get(xch_info, :guests) |> List.delete(guest)
        xch_info = Map.replace!(xch_info, :guests, new_guests)
        {:noreply, xch_info}
    end

    @impl true
    def handle_cast({:send_offer, guest, %Offer{}=offer}, xch_info) do
        xch_id = Map.get(xch_info, :xch_id)
        Map.get(xch_info, :host) |> send({xch_id, guest, offer})
        {:noreply, xch_info}
    end

end