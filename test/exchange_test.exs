defmodule ExchangeTest do
  use ExUnit.Case
  doctest Exchange.Exchange

  test "connect to server" do
    opts = [active: false]
    port = Application.get_env(:exchange, :port)
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    opcode_out = "1"
    data_out = "this is the data"
    msg_out = opcode_out <> data_out
    :ok = :gen_tcp.send(socket, msg_out)
    {:ok, msg_in} = :gen_tcp.recv(socket, 0)
    <<opcode_in, data_in :: binary>> = to_string(msg_in)
    IO.inspect <<opcode_in::utf8>>
    IO.inspect data_in
  end

end
