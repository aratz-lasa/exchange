defmodule Exchange.Exchange do
  use GenServer
  alias Exchange.User
  alias Exchange.Protocol, as: Prot
  import Exchange.Server.Utils

  def start_link({id, host} = args) do
    args = {String.to_atom(id), String.to_atom(host)}
    GenServer.start_link(__MODULE__, args, name: String.to_atom(id))
  end

  def init({id, host}) do
    {:ok,
     %{id: id, host: host, ids_guests: %{}, guests_ids: %{}, goods: [], banned: MapSet.new()}}
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
        IO.puts "#{inspect ids_guests}"
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
      new_state = delete_guest(guest, state)
                  |> Map.put(:banned, new_banned)
      response = msg_ok_user(Atom.to_string(id))
      User.receive_msg(guest, {response, Prot.guest_purged()})
      |> reply(new_state)
    else
      reply_error("Invalid guest", state)
    end
  end

  # Guest
  def handle_call({:connect_guest, guest}, _from, %{id: id, host: host} = state) do
    if check_banned(guest, state) do
      reply_error("Banned guest", state)
    else
      state = delete_guest(guest, state) # Idempotence
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
      reply_ok(to_string(id), state) # Idempotence
    end
  end

  def handle_call({:msg_to_host, guest, msg}, _from, %{id: id, host: host, guests_ids: guests_ids}=state) do
    IO.puts "#{inspect guests_ids}"
    guest_id = Map.get(guests_ids, guest)
    if guest_id != nil do
      msg = msg_ok_user(Enum.join([id, guest_id, msg], "#"))
      User.receive_msg(host, {msg, Prot.rcv_from_guest()})
      reply_ok("Msg sent to host", state)
    else
      reply_error("Invalid guest", state)
    end
  end
end
