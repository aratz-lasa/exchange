defmodule Exchange.Director do
    use GenServer
    alias Exchange.Storage
    alias Exchange.Supervisor.Exchanges

    def start_link(_args) do
        GenServer.start_link(__MODULE__, [], name: :director)
    end

    # API
    def sign_in(%User{}=user) do
        GenServer.call(:director, {:sign_in, user})
    end

    def log_in(%User{}=user) do
        GenServer.call(:director, {:log_in, user})
    end

    def sign_exchange(user) when is_map(user) do
        GenServer.call(:director, {:sign_exchange, user})
    end

    # Callbacks
    @impl true
    def init(state) do
        {:ok, state}
    end

    @impl true
    def handle_call({:sign_in, %User{}=user}, _from, state) do
        users_found = Storage.search_username(user)
        case length(users_found) do
            0 -> Storage.create_user(user)
                    |> reply(state)
            _ -> {:error, "Username already in use"}
                    |> reply(state)
        end
    end

    @impl true
    def handle_call({:log_in, %User{}=user}, _from, state) do
        users_found = Storage.search_user(user)
        case length(users_found) do
            1 -> {:ok, "Logged in"}
                  |> reply(state)
            _ -> {:error, "Incorrect username or password"}
                    |> reply(state)
        end
    end

    @impl true
    def handle_call({:sign_exchange, user}, _from, state) do
        id = Randomizer.generate!(20)
        username = Map.get(user, :username)
        {:ok, pid} = Exchanges.start_exchange({id, username})
        #TODO: check if it is correct Exchange creation
        a = [id, username]
            |> Exchange.to_struct
            |> Storage.create_exchange
            |> reply(state)
    end

    def reply(response, state) do
        {:reply, response, state}
    end
end