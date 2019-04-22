defmodule Exchange.Storage do
    def search_username(%User{}=user) do
      {:atomic, users_found} = Mnesia.transaction(
            fn ->
                Mnesia.read({User, user.username})
            end
        )

      users_found
    end

    def search_user(%User{}=user) do
      {:atomic, users_found} = Mnesia.transaction(
            fn ->
                Mnesia.read(User.to_record(user))
            end
        )
      
      users_found
    end

    def create_user(%User{}=user) do
      {:atomic, result} = Mnesia.transaction(
        fn ->
          Mnesia.write(User.to_record(user))
        end
      )
      case result do
        :ok -> {:ok, "Signed in"}
        _ -> {:error, "Failed while sign in"}
      end
    end
  end