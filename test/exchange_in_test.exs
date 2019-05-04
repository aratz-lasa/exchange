defmodule ExchangeIn do
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
    # Create exchange
    exchange_id = to_string sign_exchange(socket)
    {:ok, socket: socket, exchange_id: exchange_id}
  end

  test "connect host to exchange", state do
    socket = state[:socket]
    exchange_id = state[:exchange_id]
    opcode_out = Protocol.connect_host
    data_out = exchange_id
    msg_out = <<opcode_out>> <> data_out
    
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  test "send msg to guest", state do
    # create a guest
    port = Application.get_env(:exchange, :port)
    opts = [active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    guest_username = "dortmun"
    guest_pass = "lock"
    sign_in(socket, {guest_username, guest_pass})
    # send msg to guest
    socket = state[:socket]
    exchange_id = state[:exchange_id]
    opcode_out = Protocol.msg_to_guest
    msg = "test msg"
    data_out = Enum.join([exchange_id, guest_username, msg], "#")
    msg_out = <<opcode_out>> <> data_out
    
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  # Utils
  def sign_in(socket) do
    opcode_out = 1
    data_out = "koln#pass"
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  def sign_in(socket, {user, pass}) do
    opcode_out = 1
    data_out = Enum.join([user, pass], "#")
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
  end

  def sign_exchange(socket) do
    opcode_out = 4
    data_out = ""
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == 200
    data_in
  end
end
