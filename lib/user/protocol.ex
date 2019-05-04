defmodule Exchange.Protocol do
    import Constants, only: :macros
    
    @error_opcode 400
    @ok_opcode 200

    def decode(msg) do
        <<opcode::8, data::bitstring>> = msg
        {opcode, data}
    end

    def encode({:ok, data}) do
        <<@ok_opcode::8>> <> data
    end

    def encode({:error, data}) do
        <<@error_opcode::8>> <> data
    end

    define :sign_in, 1
    define :log_in, 2
    define :sign_exchange, 4
    define :connect_host, 5
    define :msg_to_guest, 6
end