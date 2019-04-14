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
        :ok = GenServer.call(:connect_host)
    end

    def disconnect_host(pid) do
        :ok = GenServer.call(:disconnect_host)
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

        # guest
    def join_exchange(pid) do
        :ok = GenServer.call(pid, :join_xch)
    end

    def msg_to_host(pid, guest, msg) do
        GenServer.cast(pid, {:msg_to_host, guest, msg})
    end


    # callbacks
    @impl true
    def init(host_pid) when is_pid(host_pid) do
        xch_info = %{:xch_id=>nil, :host=>host_pid, :guests=> [], :goods=>[]}
        {:ok, xch_info}
    end

    @impl true
    def handle_call({:add_xch_id, xch_id}, _from, xch_info) do
        xch_info =  Map.replace!(xch_info, :xch_id, xch_id)
        {:reply, :ok, xch_info}
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