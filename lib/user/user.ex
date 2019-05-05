defmodule Exchange.User do
    require Logger  
    use GenServer
    alias Exchange.Protocol
    alias Exchange.Execute
    alias Exchange.Log.Utils
  
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
  
    def receive_msg(name, {msg, opcode}) do
      GenServer.call(name, {:receive_msg, msg, opcode})
    end
    # Callbacks
    def handle_info({:tcp, _socket, msg}, state = %{socket: socket, transport: transport}) do
      Utils.log_msg_in(msg, state)
      {raw_response, new_state} = Protocol.decode(msg)
                                  |> Execute.execute(state)
      response = Protocol.encode(raw_response)
      Utils.log_msg_out response, state
      transport.send(socket, response)
      {:noreply, new_state}
    end

    def handle_info({:tcp_closed, _socket}, state = %{socket: socket, transport: transport}) do
      Logger.debug "Closing socket"
      
      transport.close(socket)
      {:stop, :normal, state}
    end

    def handle_call({:receive_msg, msg, opcode}, from, state = %{socket: socket, transport: transport}) do
      response = Protocol.encode(msg, opcode)
      Utils.log_msg_out response, state
      transport.send(socket, response)
      {:reply, {:ok, "Message sent"}, state}
    end
  end
  