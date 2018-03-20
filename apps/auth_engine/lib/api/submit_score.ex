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

    state = Map.put(state, :play_list, play_list)
    state = Map.put(state, :entry_id, entry_id)
    state = Map.put(state, :remaining_buffer, "")
    {[], state}
  end

  @impl Raxx.Server
  def handle_data(data, state) do
    # concat previous message left-overs with new messagee
    packets =
      (state.remaining_buffer <> data)
      |> String.split("[")

    # clear remaining_buffer and parse each complete packet and store left overs
    state =
      Map.put(state, :remaining_buffer, "")
      |> parse_loop(packets)

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
    play_list =
      Map.put(state.play_list, "entries", new_play_array)
      |> Poison.encode!()

    # push to db
    state.score_db
    |> Couchdb.Connector.Writer.create(play_list, state.entry_id)

    # send okay response
    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body("{\"s\": \"ok\"}")
  end

  def parse_loop(state, [packet | packets]) do
    state = handle_packet(state, packet)
    parse_loop(state, packets)
  end

  def parse_loop(state, []), do: state

  def handle_packet(state, packet) do
    if String.last(packet) == "]" do
      pack_segments =
        String.slice(packet, 0..-2)
        |> String.split(":")

      # TODO: if writing replay to storage, then append
      # TODO: handle incorrect array size
      # handle header if sent
      if Enum.at(pack_segments, 0) === "acc" do
        Map.put(state, :accuracy, Enum.at(pack_segments, 1))
      else
        if Enum.at(pack_segments, 0) === "score" do
          Map.put(state, :score, Enum.at(pack_segments, 1))
        else
          if Enum.at(pack_segments, 0) === "mods" do
            Map.put(state, :mods, Enum.at(pack_segments, 1))
          end
        end
      end
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
        "entries" => [],
        "top" => 0
      }
    end
  end
end
