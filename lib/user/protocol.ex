defmodule Exchange.Protocol do
  import Constants, only: :macros

  @ok_opcode 100

  def decode(msg) do
    <<opcode::8, data::bitstring>> = msg
    {opcode, data}
  end

  def encode({:ok, data}, opcode \\ @ok_opcode) do
    <<opcode::8>> <> data
  end

  def encode({:error, data}, opcode) do
    <<opcode + 75::8>> <> data
  end

  ## TCP Protocol
  # Server - OK
  define(:ok_opcode, @ok_opcode)
  define(:rcv_from_host, @ok_opcode + 1)
  define(:guest_connected, @ok_opcode + 2)
  define(:guest_disconnected, @ok_opcode + 3)
  define(:guest_purged, @ok_opcode + 4)
  define(:rcv_from_guest, @ok_opcode + 5)

  # Server - ERROR
  # All errors are the 'Correct Code' + 75
  define(:err_opcode, @ok_opcode + 75)
  define(:err_rcv_from_host, rcv_from_host + 75)
  define(:err_guest_connected, guest_connected + 75)
  define(:err_guest_disconnected, guest_disconnected + 75)
  define(:err_guest_purged, guest_purged + 75)
  define(:err_rcv_from_guest, rcv_from_guest + 75)

  # User
  define(:sign_in, 1)
  define(:log_in, 2)
  define(:sign_exchange, 4)
  define(:connect_host, 5)
  define(:msg_to_guest, 6)

  define(:purge_guest, 11)
  define(:connect_guest, 12)
  define(:disconnect_guest, 13)
  define(:msg_to_host, 16)
end
