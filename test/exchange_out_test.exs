defmodule ExchangeOut do
  use ExUnit.Case
  doctest Exchange.Exchange
  
  alias Exchange.Start
  alias Exchange.Protocol, as: Prot
  
  setup_all do
    Start.start_init_mnesia
    opts = [active: false]
    port = Application.get_env(:exchange, :port)
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    # Sign in
    sign_in(socket, {"koln", "pass"})
    {:ok, socket: socket}
  end

  
  test "log in", state do
    socket = state[:socket]
    opcode_out = Prot.log_in
    data_out = "koln#pass"
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == Prot.ok_opcode
  end

  test "sign in exchange", state do
    sign_exchange state
  end

  test "connect host to exchange", state do
    # sign exchange
    exchange_id = sign_exchange state
    
    socket = state[:socket]
    opcode_out = Prot.connect_host
    data_out = exchange_id
    msg_out = <<opcode_out>> <> data_out
    
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == Prot.ok_opcode
  end

  test "connect guest to exchange", state do
    # sign exchange
    exchange_id = sign_exchange state
    # sign in guest
    port = Application.get_env(:exchange, :port)
    opts = [active: false]
    {:ok, guest_socket} = :gen_tcp.connect('localhost', port, opts)
    sign_in guest_socket, {"dortmund", "pass"}
    # connect guest to exchange
    opcode_out = Prot.connect_guest
    data_out = exchange_id
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(guest_socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(guest_socket, 0)
    [opcode_in | guest_id] = msg_in
    assert opcode_in == Prot.ok_opcode
    # Check in host notification
    socket = state[:socket]
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | guest_id] = msg_in
    assert opcode_in == Prot.guest_connected
  end

  # Utils
  def sign_exchange(state) do 
    socket = state[:socket]
    opcode_out = Prot.sign_exchange
    data_out = ""
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | exchange_id] = msg_in
    assert opcode_in == Prot.ok_opcode
    to_string exchange_id
  end

  def sign_in(socket, {user, pass}) do
    opcode_out = Prot.sign_in
    data_out = Enum.join([user, pass], "#")
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == Prot.ok_opcode
  end
end
