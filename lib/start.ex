defmodule Exchange.Start do
    use Application

    def start(_type, _args) do
        children = [{Exchange.FrontEnd, []}]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
end