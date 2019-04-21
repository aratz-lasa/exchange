defmodule Exchange.Protocol do
    def parse_msg(msg) do
        <<opcode, data::bitstring>> = msg
        {<<opcode>>, data}
    end

end