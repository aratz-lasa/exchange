defmodule ExchangeInGuest do
  use ExUnit.Case
  doctest Exchange.Exchange

  alias Exchange.Start
  alias Exchange.Protocol, as: Prot

  setup_all do
    Start.start_init_mnesia()
    # Sign in
    socket = sign_in("koln", "pass")
    # Create exchange
    exchange_id = sign_exchange(socket)
    # Create guest 
    guest_socket = sign_in("dortmund", "pass")
    # Connect guest
    guest_id = connect_guest(guest_socket, exchange_id)
    # For reading guest connection  to Exchange
    :gen_tcp.recv(socket, 0)

    {:ok,
     socket: socket, guest_socket: guest_socket, exchange_id: exchange_id, guest_id: guest_id}
  end

  test "disconnect guest", state do
    guest_socket = state[:guest_socket]
    exchange_id = state[:exchange_id]
    guest_id = state[:guest_id]
    # disconnect guest
    opcode_out = Prot.disconnect_guest()
    data_out = exchange_id
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(guest_socket, msg_out)
    # Check in guest socket
    {:ok, msg_in} = :gen_tcp.recv(guest_socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == Prot.ok_opcode()
    # Check in host socket
    socket = state[:socket]
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == Prot.guest_disconnected()
    [from, what] = String.split(to_string(data_in), "#")
    assert from == exchange_id
    assert what == guest_id
  end

  # Utils
  def sign_in(user, pass) do
    # Create TCP connection
    opts = [active: false]
    port = Application.get_env(:exchange, :port)
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    # Sign in
    opcode_out = Prot.sign_in()
    data_out = Enum.join([user, pass], "#")
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | data_in] = msg_in
    assert opcode_in == Prot.ok_opcode()
    socket
  end

  def connect_guest(socket, exchange_id) do
    opcode_out = Prot.connect_guest()
    data_out = exchange_id
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | guest_id] = msg_in
    assert opcode_in == Prot.ok_opcode()
    to_string(guest_id)
  end

  def sign_exchange(socket) do
    opcode_out = Prot.sign_exchange()
    data_out = ""
    msg_out = <<opcode_out>> <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    [opcode_in | exchange_id] = msg_in
    assert opcode_in == Prot.ok_opcode()
    to_string(exchange_id)
  end
end
