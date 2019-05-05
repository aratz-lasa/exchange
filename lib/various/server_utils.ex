defmodule Exchange.Server.Utils do
    def check_banned(guest, state) do
        state
         |> Map.get(:banned)
         |> MapSet.member?(guest)
    end

    def reply_error(response, state) do
        reply({:error, response}, state)
    end

    def reply_ok(response, state) do
        reply({:ok, response}, state)
    end

    def reply(response, state) do
        {:reply, response, state}
    end
end