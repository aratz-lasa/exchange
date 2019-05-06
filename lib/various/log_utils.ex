defmodule Exchange.Log.Utils do
  require Logger

  def log_msg_in(msg_in, state) do
    Logger.debug("Msg-in: #{IO.inspect(msg_in)}")
    Logger.debug("State-in: #{inspect(state)}")
  end

  def log_msg_out(msg_out, state) do
    Logger.debug("Msg-out: #{IO.inspect(msg_out)}")
    Logger.debug("State-out: #{inspect(state)}")
  end
end
