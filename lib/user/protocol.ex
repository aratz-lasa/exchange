defmodule Exchange.Protocol do
    def decode(msg) do
        <<opcode::8, data::bitstring>> = msg
        {opcode, data}
    end

    def encode(msg) do
        #TODO: decide how to encode response
    end

end