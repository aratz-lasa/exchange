defmodule Exchange.Protocol do
    def decode(msg) do
        <<opcode::8, data::bitstring>> = msg
        {opcode, data}
    end

    def encode({opcode, data}) do
        opcode <> data
    end

end