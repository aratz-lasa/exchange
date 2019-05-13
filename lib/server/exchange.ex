defmodule Exchange.Exchange do
  use GenServer
  alias Exchange.User
  alias Exchange.Protocol, as: Prot
  import Exchange.Server.Utils

  def start_link({id, host}) do
    args = {String.to_atom(id), String.to_atom(host)}
    GenServer.start_link(__MODULE__, args, name: String.to_atom(id))
  end

  def init({id, host}) do
    {:ok,
     %{id: id, host: host, ids_guests: %{}, 
     guests_ids: %{}, goods: %{}, banned: MapSet.new(),
     offers: %{}}}
  end

  ## API
  # Host
  def connect_host(id, host) do
    GenServer.call(id, {:connect_host, String.to_atom(host)})
  end

  def msg_to_guest(id, {guest_id, msg}) do
    GenServer.call(id, {:msg_to_guest, guest_id, msg})
  end

  def ban_guest(id, guest_id) do
    GenServer.call(id, {:ban_guest, guest_id})
  end

  def add_good(id, %Good{} = good) do
    GenServer.call(id, {:add_good, good})
  end

  def accept_offer(id, offer_id) do
    GenServer.call(id, {:accept_offer, offer_id})
  end

  # Guest
  def connect_guest(id, guest) do
    GenServer.call(id, {:connect_guest, String.to_atom(guest)})
  end

  def disconnect_guest(id, guest) do
    GenServer.call(id, {:disconnect_guest, String.to_atom(guest)})
  end

  def msg_to_host(id, guest, msg) do
    GenServer.call(id, {:msg_to_host, String.to_atom(guest), msg})
  end

  def get_goods(id) do
    GenServer.call(id, :get_goods)
  end

  def send_offer(id, guest, offer) do
    GenServer.call(id, {:send_offer, String.to_atom(guest), offer})
  end

  ## Callbacks
  # Host
  def handle_call({:connect_host, host}, _from, state) do
    new_state = Map.put(state, :host, host)
    reply_ok("Host connected", new_state)
  end

  def handle_call(
        {:msg_to_guest, guest_id, msg},
        _from,
        state = %{id: id, ids_guests: ids_guests}
      ) do
    guest = Map.get(ids_guests, guest_id)

    if guest != nil do
      response = msg_ok_user(Enum.join([id, msg], "#"))

      User.receive_msg(guest, {response, Prot.rcv_from_host()})
      |> reply(state)
    else
      reply_error("Invalid guest", state)
    end
  end

  def handle_call(
        {:ban_guest, guest_id},
        _from,
        state = %{id: id, ids_guests: ids_guests, banned: banned}
      ) do
    guest = Map.get(ids_guests, guest_id)

    if guest != nil do
      new_banned = MapSet.put(banned, guest)

      new_state =
        delete_guest(guest, state)
        |> Map.put(:banned, new_banned)

      response = msg_ok_user(Atom.to_string(id))

      User.receive_msg(guest, {response, Prot.guest_banned()})
      |> reply(new_state)
    else
      reply_error("Invalid guest", state)
    end
  end

  def handle_call(
        {:add_good, good},
        _from,
        %{id: id, goods: goods, ids_guests: ids_guests} = state
      ) do
    # if nil, means it is a new good
    good =
      if good.id == "" or good.id == nil do
        good_id = Randomizer.generate!(20)
        Map.put(good, :id, good_id)
      else
        good
      end

    # Idempotence
    new_goods = Map.put(goods, good.id, good)
    new_state = Map.put(state, :goods, new_goods)
    # Notify guests
    Enum.each(ids_guests, fn {_, guest} ->
      data = Enum.join([Atom.to_string(id), Good.encode(good)], "#")
      msg = msg_ok_user(data)
      User.receive_msg(guest, {msg, Prot.good_added()})
    end)

    reply_ok(Good.encode(good), new_state)
  end

  def handle_call({:accept_offer, offer_id}, _from, %{id: id, offers: offers}=state) do 
    guest = Map.get(offers, offer_id)
    msg = msg_ok_user(to_string(id) <> "#" <> offer_id)
    User.receive_msg(guest, {msg, Prot.offer_accepted()})
    new_offers = Map.delete(offers, offer_id)
    new_state = Map.put(state, :offers, new_offers)
    reply_ok("Offer accepted", new_state)
  end

  # Guest
  def handle_call({:connect_guest, guest}, _from, %{id: id, host: host} = state) do
    if check_banned(guest, state) do
      reply_error("Banned guest", state)
    else
      # Idempotence
      state = delete_guest(guest, state)
      guest_id = Randomizer.generate!(20)

      new_guests_ids =
        Map.get(state, :guests_ids)
        |> Map.put(guest, guest_id)

      new_ids_guests =
        Map.get(state, :ids_guests)
        |> Map.put(guest_id, guest)

      new_state =
        Map.put(state, :guests_ids, new_guests_ids)
        |> Map.put(:ids_guests, new_ids_guests)

      msg = msg_ok_user(Enum.join([id, guest_id], "#"))
      User.receive_msg(host, {msg, Prot.guest_connected()})
      reply_ok(guest_id, new_state)
    end
  end

  def handle_call(
        {:disconnect_guest, guest},
        _from,
        %{id: id, host: host, guests_ids: guests_ids, ids_guests: ids_guests} = state
      ) do
    guest_id = Map.get(guests_ids, guest)

    if guest_id != nil do
      new_ids_guests = Map.delete(ids_guests, guest_id)
      new_guests_ids = Map.delete(guests_ids, guest)

      new_state =
        state
        |> Map.put(:guests_ids, new_guests_ids)
        |> Map.put(:ids_guests, new_ids_guests)

      msg = msg_ok_user(Enum.join([id, guest_id], "#"))
      User.receive_msg(host, {msg, Prot.guest_disconnected()})
      reply_ok(to_string(id), new_state)
    else
      # Idempotence
      reply_ok(to_string(id), state)
    end
  end

  def handle_call(
        {:msg_to_host, guest, msg},
        _from,
        %{id: id, host: host, guests_ids: guests_ids} = state
      ) do
    guest_id = Map.get(guests_ids, guest)

    if guest_id != nil do
      msg = msg_ok_user(Enum.join([id, guest_id, msg], "#"))
      User.receive_msg(host, {msg, Prot.rcv_from_guest()})
      reply_ok("Msg sent to host", state)
    else
      reply_error("Invalid guest", state)
    end
  end

  def handle_call(:get_goods, _from, %{id: id, goods: goods} = state) do
    [to_string(id) | Map.values(goods)]
    |> Enum.reduce(fn x, acc -> acc <> "#" <> Good.encode(x) end)
    |> reply_ok(state)
  end

  def handle_call({:send_offer, guest, offer}, _from, %{id: id, host: host, guests_ids: guests_ids, offers: offers} = state) do
    offer = Map.put(offer, :id, Randomizer.generate!(20))
    encoded_offer = Offer.encode(offer)
    guest_id = Map.get(guests_ids, guest) # TODO: check guest exists
    msg = msg_ok_user(Enum.join([to_string(id),guest_id,encoded_offer], "#"))
    User.receive_msg(host, {msg, Prot.rcv_offer()})
    new_offers = Map.put(offers, offer.id, guest)
    new_state = Map.put(state, :offers, new_offers)
    reply_ok(encoded_offer, new_state)
  end
end
