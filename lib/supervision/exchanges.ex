defmodule Exchange.Supervisor.Exchanges do
    use DynamicSupervisor
    alias Exchange.Exchange

    def start_link(arg) do
        DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
    end

    @impl true
    def init(_arg) do
        DynamicSupervisor.init(strategy: :one_for_one)
    end

    def start_exchange(args) do
        DynamicSupervisor.start_child(__MODULE__, {Exchange, args})
    end
end