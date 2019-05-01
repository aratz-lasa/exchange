defmodule ExchangeTest do
  use ExUnit.Case
  doctest Exchange.Exchange
  
  
  setup_all do
    opts = [active: false]
    port = Application.get_env(:exchange, :port)
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    opcode_out = 1
    data_out = "koln#pass"
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
    {:ok, socket: socket}
  end

  
  test "sign in & log in", state do
    socket = state[:socket]
    opcode_out = 2
    data_out = "koln#pass"
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  test "sign in exchange", state do
    socket = state[:socket]
    opcode_out = 4
    data_out = ""
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end
end
