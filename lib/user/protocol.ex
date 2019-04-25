defmodule Exchange.Protocol do
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

end