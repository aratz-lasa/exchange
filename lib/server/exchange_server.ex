defmodule ExchangeServer do
    use GenServer
    
    # Client API
    def start_link(default) when is_map(default) do
        GenServer.start_link(__MODULE__, default)
    end

    def start_link() do
      GenServer.start_link(__MODULE__, %{})
    end

    def sign(pid, xch_pid) do
        GenServer.call(pid, {:sign, xch_pid})
    end

    def purge(pid, xch_id) do
      GenServer.cast(pid, {:purge, xch_id})
    end

    def resolve(pid, xch_id) do
        GenServer.call(pid, {:resolve, xch_id})
    end


    # Callbacks
  
    @impl true
    def init(exchange_registry) do
      Process.register(self(), :exchange_server)
      {:ok, exchange_registry}
    end
  
    @impl true
    def handle_call({:sign, xch_pid}, _from, exchange_registry) do
      xch_id = Randomizer.generate!(20)
      exchange_registry = Map.put(exchange_registry, xch_id, xch_pid)
      :ok = Exchange.add_xch_id(xch_pid, xch_id)
      {:reply, {:ok, xch_id}, exchange_registry}
    end
    
    @impl true
    def handle_call({:resolve, xch_id}, _from, exchange_registry) do
      xch_pid = Map.get(exchange_registry, xch_id)
      {:reply, {:ok, xch_pid}, exchange_registry}
    end

    @impl true
    def handle_cast({:purge, xch_id}, exchange_registry) do
      exchange_registry = Map.delete(exchange_registry, xch_id)
      :ok
      {:noreply, exchange_registry}
    end
  end