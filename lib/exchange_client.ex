defmodule ExchangeClient do
    use GenStateMachine
    
    # Client API
    def start_link(%{:server_pid=>_}=default) do
        GenStateMachine.start_link(__MODULE__, default)
    end

    def connect(pid, exchange_code) do
        GenStateMachine.cast(pid, {:connect, exchange_code})
    end
    
    def is_connected(pid) do
        GenStateMachine.call(pid, :is_connected)
    end
    # Callbacks
  
  @impl true
  def init(data) when is_map(data) do
    {:ok, :searching, data}
  end

  @impl true
  def handle_event(:cast, {:connect, exchange_code}, :searching, data) do
    server_pid = Map.get(data, :server_pid)
    exchange_pid = ExchangeServer.connect(server_pid, exchange_code)
    cond do
        is_nil(exchange_pid) -> :keep_state_and_data
        true -> data = Map.put(data, :exchande_pid, exchange_pid)
            IO.puts "Exchange PID #{inspect exchange_pid}"
            {:next_state, :connected, data}
    end    
  end

  @impl true
  def handle_event({:call, from}, :is_connected, :connected, _data) do
    {:keep_state_and_data, [{:reply, from, true}]} 
  end

  @impl true
  def handle_event({:call, from}, :is_connected, _state, _data) do
    {:keep_state_and_data, [{:reply, from, false}]} 
  end
end