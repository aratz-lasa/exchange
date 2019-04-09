defmodule ExchangeClient do

    def receive_msg(pid, msg) do
        GenStateMachine.cast(pid, {:read, msg})
    end

    def send_msg(pid, msg) do
        GenStateMachine.cast(pid, {:write, msg})
    end        
     
end