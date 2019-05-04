defmodule Exchange.Execute.Utils do
    def execute_new_user(fun, data, state) do
        user = String.split(data, "#") 
        case user do
            [username, password] -> 
                User.to_struct(user)
                    |> fun.()
                    |> check_regist_user(username)
                    |> respond {Map.put(state, :user, User.to_struct(user)), state}
            _ -> respond_error("Invalid input", state)
        end
    end

    def check_regist_user(result, username) do
        username = String.to_atom username
        case result do
            {:ok, data} -> 
                if not is_nil Process.whereis(username) do
                    Process.unregister(username)
                end
                Process.register self, username
            _ ->
        end
        result
    end

    def parse_msg_to_guest(data) when is_binary(data) do
        [exchange | rest_msg] = String.split(data, "#")
        [guest_id | msg] = rest_msg
        {String.to_atom(exchange), guest_id, msg}
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