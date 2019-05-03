defmodule Exchange.Execute.Utils do
    def execute_new_user(fun, data, state) do
        user = String.split(data, "#") 
        case user do
            [username, password] -> 
                User.to_struct(user)
                    |> fun.()
                    |> respond {Map.put(state, :user, User.to_struct(user)), state}
            _ -> respond_error("Invalid input", state)
        end
    end

    def parse_exchange_msg(data) when is_binary(data) do
        [exchange| rest_msg] = String.split(data, "#")
        [guest | msg] = rest_msg
        {exchange, guest, to_string(msg)}
    end

    def respond(result, state) when not is_tuple(state) do
        case result do
            {:ok, data} ->
                respond_ok data, state
            {:error, data} ->
                respond_error data, state
            _ ->
                respond_error "Error processing request", state
        end
    end

    def respond(result, {ok_state, error_state}) do
        case result do
            {:ok, data} ->
                respond_ok data, ok_state
            {:error, data} ->
                respond_error data, error_state
            _ ->
                respond_error "Error processing request", error_state
        end
    end

    def respond_ok(data, state) do
        {{:ok, data}, state}
    end

    def respond_error(data, state) do
        {{:error, data}, state}
    end
    

end