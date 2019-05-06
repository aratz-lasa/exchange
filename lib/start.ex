defmodule Exchange.Start do
  use Application
  alias :mnesia, as: Mnesia

  def start(_type, _args) do
    start_init_mnesia
    # Start children
    children = [{Exchange.Supervisor.Director.Exchanges, []}, {Exchange.FrontEnd, []}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_init_mnesia() do
    # Just in case stop Mnesia
    Mnesia.stop()
    # Start Mnesia    
    Mnesia.create_schema([node()])
    Mnesia.start()
    # Initialize tables
    Mnesia.create_table(User, attributes: User.attributes())
    Mnesia.create_table(Offer, attributes: Offer.attributes())
    Mnesia.create_table(Good, attributes: Good.attributes())
    Mnesia.create_table(Exchange, attributes: Exchange.attributes())
  end
end
