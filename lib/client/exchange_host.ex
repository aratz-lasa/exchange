defmodule ExchangeHost do
    use GenStateMachine
    
    # Client API
    def start_link(%{:server_pid=>_}=default) when is_map(default) do
        GenStateMachine.start_link(__MODULE__, default)
    end

    def start_link(server_pid) when is_pid(server_pid) do
      default = %{:server_pid=>server_pid}
      GenStateMachine.start_link(__MODULE__, default)
    end

    def sign(pid, xch_pid) do
        GenStateMachine.cast(pid, {:sign, xch_pid})
    end

    def unsign(pid) do
      GenStateMachine.cast(pid, :unsign)
    end
    
    def connect(pid, guest_pid) do
      GenStateMachine.cast(pid, {:connect, guest_pid})
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
  def handle_event(:cast, {:sign, xch_pid}, :unsigned, data) do
    server_pid = Map.get(data, :server_pid)
    exchange_code = ExchangeServer.sign(server_pid, xch_pid)
    IO.puts "Exchange Code #{inspect exchange_code}"
    data = Map.put(data, :exchange_code, exchange_code) 
    {:next_state, :signed, data}
  end

  @impl true
  def handle_event(:cast, :unsign, :signed, data) do
    server_pid = Map.get(data, :server_pid)
    exchange_code = Map.get(data, :exchange_code)
    ExchangeServer.purge(server_pid, exchange_code)
  end

  def handle_event(:cast, {:connect, guest_pid}, :signed, data) do
    data = Map.put(data, :exchange_pid, guest_pid)
    {:next_state, :connected, data}   
  end

  @impl true
  def handle_event({:call, from}, :is_signed, state, _data) do
    case state do
        :unsigned -> 
          {:keep_state_and_data, [{:reply, from, false}]} 
        _ ->
          {:keep_state_and_data, [{:reply, from, true}]} 
          
    end
  end
  
  # ExchangeClient methods
  @impl true
  def handle_event(:cast, {:write, msg}, :connected, data) do
    exchange_pid = Map.get(data, :exchange_pid)
    ExchangeClient.receive_msg(exchange_pid, msg)
    IO.puts "Sent to #{inspect exchange_pid} - #{msg}"
    :keep_state_and_data
  end

  @impl true
  def handle_event(:cast, {:read, msg}, :connected, _data) do
    IO.puts msg
    :keep_state_and_data
  end

end