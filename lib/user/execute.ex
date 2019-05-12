defmodule Exchange.Execute do
  alias Exchange.Director
  import Exchange.Execute.Utils
  alias Exchange.Exchange, as: Xch
  # sign-in
  def execute({1, data}, state) do
    execute_new_user(&Director.sign_in/1, data, state)
  end

  # log-in
  def execute({2, data}, state) do
    execute_new_user(&Director.log_in/1, data, state)
  end

  # retrieve unread data
  def execute({3, data}, state) do
  end

  ## HOST
  # sign exchange
  def execute({4, data}, state) do
    if Map.has_key?(state, :user) do
      Map.get(state, :user)
      |> Director.sign_exchange()
      |> respond(state)
    else
      respond_error("Not logged in", state)
    end
  end

  # connect host to exchange
  def execute({5, data}, state) do
    exchange = String.to_atom(data)
    host_name = Map.get(state, :user).username

    Xch.connect_host(exchange, host_name)
    |> respond(state)
  end

  # send message to guest
  def execute({6, data}, state) do
    {exchange, guest_id, msg} = parse_msg_to_guest(data)
    response = Xch.msg_to_guest(exchange, {guest_id, msg})
    respond(response, state)
  end

  # add good to exhchange
  def execute({7, data}, %{user: user} = state) do
    [exchange | good] = String.split(data, "#", parts: 2)
    good = Good.decode(to_string(good))
    response = Xch.add_good(String.to_atom(exchange), good)
    respond(response, state)
  end

  # accept offer
  def execute({8, data}, state) do
  end

  # decline offer
  def execute({9, data}, state) do
  end

  # purge exchange
  def execute({10, data}, state) do
  end

  # ban guest from exchange
  def execute({11, data}, state) do
    [exchange, guest_id] = String.split(data, "#", parts: 2)

    Xch.ban_guest(String.to_atom(exchange), guest_id)
    |> respond(state)
  end

  ## GUEST
  # connect guest to exchange
  def execute({30, data}, %{user: user} = state) do
    exchange = String.to_atom(data)
    guest = user.username

    Xch.connect_guest(exchange, guest)
    |> respond(state)
  end

  # disconnect guest from exchange
  def execute({31, data}, state) do
    exchange = String.to_atom(data)
    guest = Map.get(state, :user).username

    Xch.disconnect_guest(exchange, guest)
    |> respond(state)
  end

  # get exchange goods
  def execute({32, data}, state) do
    String.to_atom(data)
    |> Xch.get_goods()
    |> respond(state)
  end

  # send offer to host
  def execute({34, data}, state) do
    [exchange | offer] = String.split(data, "#", parts: 4)
    offer = Offer.to_struct([nil | offer]) # Offer_id == nil
    response = Xch.send_offer(String.to_atom(exchange), offer)
    respond(response, state)
  end

  # send message to host
  def execute({35, data}, %{user: user} = state) do
    [exchange, msg] = String.split(data, "#", parts: 2)
    guest = user.username

    Xch.msg_to_host(String.to_atom(exchange), guest, msg)
    |> respond(state)
  end
end
