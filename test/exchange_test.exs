defmodule ExchangeTest do
  use ExUnit.Case
  doctest Exchange.Exchange

  test "connect to server" do
    opts = [active: false]
    port = Application.get_env(:exchange, :port)
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
  end

end
