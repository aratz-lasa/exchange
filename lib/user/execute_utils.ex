defmodule Exchange.Execute.Utils do
    def execute_new_user(fun, data, state) do
        user = String.split(data, "#") 
        case user do
            [username, password] -> 
                User.to_struct(user)
                    |> fun.()
                    |>case do
                        {:ok, data} ->
                            new_state = Map.put(state, :user, User.to_struct(user))
                            respond_ok(data, new_state)
                        _ -> 
                            respond_error(data, state)
                        end
            _ -> respond_error("Invalid input", state)
        end
    end

    def respond_ok(data, state) do
        {{:ok, data}, state}
    end

    def respond_error(data, state) do
        {{:error, data}, state}
    end
    
end