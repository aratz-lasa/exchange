defmodule ExchangeOut do
  use ExUnit.Case
  doctest Exchange.Exchange
  
  alias Exchange.Start
  alias Exchange.Protocol
  
  setup_all do
    Start.start_init_mnesia
    opts = [active: false]
    port = Application.get_env(:exchange, :port)
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    # Sign in
    sign_in(socket)
    {:ok, socket: socket}
  end

  
  test "log in", state do
    socket = state[:socket]
    opcode_out = Protocol.log_in
    data_out = "koln#pass"
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  test "sign in exchange", state do
    socket = state[:socket]
    opcode_out = Protocol.sign_exchange
    data_out = ""
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  # Utils
  def sign_in(socket) do
    opcode_out = Protocol.sign_in
    data_out = "koln#pass"
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end
end
