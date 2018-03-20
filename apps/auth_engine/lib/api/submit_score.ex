defmodule Api.SubmitScore do
  use Raxx.Server

  @impl Raxx.Server
  def handle_head(req, state) do
    # extract user id and track id from url
    [_, entry_id] = req.path

    # fetch the entry object from the db
    play_list =
      state.score_db
      |> Couchdb.Connector.Reader.get(entry_id)
      |> extract_plays()

    Map.put(state, :play_list, play_list)
    Map.put(state, :entry_id, entry_id)
    Map.put(state, :remaining_buffer, "")
    {[], state}
  end

  @impl Raxx.Server
  def handle_data(data, state) do
    # concat previous message left-overs with new messagee
    packets =
      (state.remaining_buffer <> data)
      |> String.split("[")

    # clear remaining_buffer
    Map.put(state, :remaining_buffer, "")

    # parse each complete packet and store left overs
    Enum.each(packets, fn packet ->
      handle_packet(packet, state)
    end)

    {[], state}
  end

  @impl Raxx.Server
  def handle_tail(_trailers, state) do
    # TODO: submit replay file to be valiated and ensure its valid/not hacked

    # create entry for db from replay file values
    play = gen_play_entry(state.score, state.mods, state.accuracy)

    # append new play entry to array of play entries (performant way)
    new_play_array =
      [play | state.play_list["entries"]]
      |> List.flatten()

    # update play list to have new entries list
    Map.put(state.play_list, "entries", new_play_array)

    # push to db
    state.track_db
    |> Couchdb.Connector.Writer.create(state.play_list, state.entry_id)

    # send okay response
    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body("{\"s\": \"ok\"}")
  end

  def handle_packet(packet, state) do
    if String.last(packet) == "]" do
      pack_segments =
        String.slice(packet, 0..-2)
        |> String.split(":")

      # TODO: handle incorrect array size
      # handle header if sent
      cond do
        pack_segments[0] == "acc" ->
          Map.put(state, :accuracy, pack_segments[1])

        pack_segments[0] == "score" ->
          Map.put(state, :score, pack_segments[1])

        pack_segments[0] == "mods" ->
          Map.put(state, :mods, pack_segments[1])
      end

      # TODO: if writing replay to storage, then append
    else
      Map.put(state, :remaining_buffer, packet)
    end
  end

  def gen_play_entry(score, mods, accuracy) do
    %{
      score: score,
      mods: mods,
      acc: accuracy,
      id: UUID.uuid4(),
      time: System.system_time(:nanosecond)
    }
  end

  def extract_plays(user_lookup) do
    {status, play_list} = user_lookup

    if status == :ok do
      Poison.decode!(play_list)
    else
      %{
        entries: [],
        top: 0
      }
    end
  end
end
