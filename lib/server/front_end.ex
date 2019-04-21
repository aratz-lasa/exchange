defmodule Exchange.FrontEnd do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_args) do
    port = Application.get_env(:exchange,:port)
    opts = [{:port, port}]
    :ranch.start_listener(:exchange_front_end, :ranch_tcp, opts, Exchange.User, [])
  end

end
