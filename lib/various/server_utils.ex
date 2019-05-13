defmodule Exchange.Server.Utils do
  alias Exchange.User

  def check_banned(guest, state) do
    state
    |> Map.get(:banned)
    |> MapSet.member?(guest)
  end

  def handle_offer({opcode, offer_id}, %{id: id, offers: offers} = state) do
    guest = Map.get(offers, offer_id)
    msg = msg_ok_user(to_string(id) <> "#" <> offer_id)
    User.receive_msg(guest, {msg, opcode})
    new_offers = Map.delete(offers, offer_id)
    new_state = Map.put(state, :offers, new_offers)
    reply_ok("Offer handled", new_state)
  end

  def delete_guest(guest, %{ids_guests: ids_guests, guests_ids: guests_ids} = state) do
    guest_id = Map.get(guests_ids, guest)

    if guest_id != nil do
      new_guests_ids = Map.delete(guests_ids, guest)
      new_ids_guests = Map.delete(ids_guests, guest_id)

      new_state =
        Map.put(state, :guests_ids, new_guests_ids)
        |> Map.put(:ids_guests, new_ids_guests)

      new_state
    else
      state
    end
  end

  def reply_error(response, state) do
    reply({:error, response}, state)
  end

  def reply_ok(response, state) do
    reply({:ok, response}, state)
  end

  def reply(response, state) do
    {:reply, response, state}
  end

  def msg_ok_user(response) do
    {:ok, response}
  end

  def msg_error_user(response) do
    {:error, response}
  end
end
