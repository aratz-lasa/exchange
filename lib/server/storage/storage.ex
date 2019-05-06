defmodule Exchange.Storage do
  require User
  alias :mnesia, as: Mnesia

  def search_username(%User{} = user) do
    {:atomic, users_found} =
      Mnesia.transaction(fn ->
        Mnesia.read({User, user.username})
      end)

    users_found
  end

  def search_user(%User{} = user) do
    {:atomic, users_found} =
      Mnesia.transaction(fn ->
        Mnesia.match_object(User.to_record(user))
      end)

    users_found
  end

  def create_user(%User{} = user) do
    {:atomic, result} =
      Mnesia.transaction(fn ->
        Mnesia.write(User.to_record(user))
      end)

    case result do
      :ok -> {:ok, "Signed in"}
      _ -> {:error, "Failed while sign in"}
    end
  end

  def create_exchange(%Exchange{} = exchange) do
    {:atomic, result} =
      Mnesia.transaction(fn ->
        Mnesia.write(Exchange.to_record(exchange))
      end)

    case result do
      :ok -> {:ok, exchange.id}
      _ -> {:error, "Failed to create exchange"}
    end
  end
end
