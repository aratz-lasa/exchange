defmodule ExchangeServer do
    use GenServer
    
    # Client API
    def start_link(default) when is_map(default) do
        GenServer.start_link(__MODULE__, default)
    end

    def start_link() do
      GenServer.start_link(__MODULE__, %{})
    end

    def sign(pid) do
        GenServer.call(pid, :sign)
    end

    def purge(pid, exchange_id) do
      GenServer.cast(pid, {:purge, exchange_id})
    end

    def connect(pid, exchange_id) do
        GenServer.call(pid, {:connect, exchange_id})
    end


    # Callbacks
  
    @impl true
    def init(exchange_registry) do
      {:ok, exchange_registry}
    end
  
    @impl true
    def handle_call(:sign, from, exchange_registry) do
      exchange_id = Randomizer.generate!(20)
      {pid, _} = from
      exchange_registry = Map.put(exchange_registry, exchange_id, pid)
      {:reply, exchange_id, exchange_registry}
    end
    
    @impl true
    def handle_call({:connect, exchange_id}, _from, exchange_registry) do
      pid = Map.get(exchange_registry, exchange_id)
      {:reply, pid, exchange_registry}
    end

    @impl true
    def handle_cast({:purge, exchange_id}, exchange_registry) do
      exchange_registry = Map.delete(exchange_registry, exchange_id)
      :ok
      {:noreply, exchange_registry}
    end
  end