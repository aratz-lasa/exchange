defmodule ExchangeGuest do
  
  use GenStateMachine
    
  # Client API
  def start_link(%{:server_pid=>_}=default) when is_map(default) do
    GenStateMachine.start_link(__MODULE__, default)
  end

  def start_link(server_pid) when is_pid(server_pid) do
    default = %{:server_pid=>server_pid}
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
    exchange_pid = ExchangeServer.resolve(server_pid, exchange_code)
    cond do
        is_nil(exchange_pid) ->
          :keep_state_and_data
        true -> 
          data = Map.put(data, :exchange_pid, exchange_pid)
          Map.get(data, :exchande_pid)
          ExchangeHost.connect(exchange_pid, self())
          IO.puts "Exchange PID #{inspect exchange_pid}"
          # TODO: start exchange notifier
          {:next_state, :connected, data}
    end    
  end

  @impl true
  def handle_event({:call, from}, :is_connected, state, _data) do
    case state do
      :connected -> {:keep_state_and_data, [{:reply, from, true}]} 
      _ -> {:keep_state_and_data, [{:reply, from, false}]} 
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