defmodule Exchange.User do
    require Logger  
    use GenServer
    alias Exchange.Protocol
    alias Exchange.Execute
  
    @behaviour :ranch_protocol
  
    def start_link(ref, socket, transport, _opts) do
      pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
      {:ok, pid}
    end
  
    def init(ref, socket, transport) do
      Logger.debug "Starting socket"
  
      :ok = :ranch.accept_ack(ref)
      :ok = transport.setopts(socket, [{:active, true}])
      :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
    end
  
    def handle_info({:tcp, _socket, msg}, state = %{socket: socket, transport: transport}) do
      Logger.debug "Received msg: #{IO.inspect msg}"
      
      {raw_response, new_state} = Protocol.decode(msg)
                                  |> Execute.execute(state)
      response = Protocol.encode(raw_response)
      
      Logger.debug "State: #{inspect(new_state)}"
      
      Logger.debug "Response: #{IO.inspect response}"
      
      transport.send(socket, response)
      {:noreply, new_state}
    end

    def handle_info({:tcp_closed, _socket}, state = %{socket: socket, transport: transport}) do
      Logger.debug "Closing socket"
      
      transport.close(socket)
      {:stop, :normal, state}
    end
  end
  