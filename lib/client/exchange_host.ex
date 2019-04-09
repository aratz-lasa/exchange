defmodule ExchangeHost do
    use GenStateMachine
    
    # Client API
    def start_link(%{:server_pid=>_}=default) do
        GenStateMachine.start_link(__MODULE__, default)
    end

    def connect(pid, exchange_code) do
        GenStateMachine.cast(pid, {:connect, exchange_code})
    end
    
    def is_signed(pid) do
        GenStateMachine.call(pid, :is_signed)
    end
    # Callbacks
  
  @impl true
  def init(data) when is_map(data) do
    {:ok, :unsigned, data}
  end

  @impl true
  def handle_event(:cast, :sign, :unsigned, data) do
    server_pid = Map.get(data, :server_pid)
    exchange_code = ExchangeServer.sign(server_pid)
    IO.puts "Exchange Code #{inspect exchange_code}"
    data = Map.put(data, :exchange_code, exchange_code)
    # TODO: start exchange notifier  
    {:next_state, :signed, data}
  end

  @impl true
  def handle_event(:cast, {:write, msg}, :signed, data) do
    exchange_pid = Map.get(data, :exchange_pid)
  end

  @impl true
  def handle_event({:call, from}, :is_signed, state, _data) do
    case state do
        :signed -> {:keep_state_and_data, [{:reply, from, true}]} 
        _ -> {:keep_state_and_data, [{:reply, from, false}]} 
    end
  end
  
end