defmodule Exchange.FrontEnd do
  use Agent

  def start_link(_args) do
    port = Application.get_env(:exchange,:port)
    opts = [{:port, port}]
    :ranch.start_listener(:exchange_front_end, :ranch_tcp, opts, ExchangeUser, [])
  end

end
