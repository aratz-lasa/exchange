defmodule Exchange.Start do
    use Application
    alias :mnesia, as: Mnesia

    def start(_type, _args) do
        # Start Mnesia    
        Mnesia.create_schema([node()])
        Mnesia.start()
        # Initialize tables
        Mnesia.create_table(User, [attributes: User.attributes()])
        Mnesia.create_table(Offer, [attributes: Offer.attributes()])
        Mnesia.create_table(Good, [attributes: Good.attributes()])

        # Start children
        children = [{Exchange.FrontEnd, []}]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
end