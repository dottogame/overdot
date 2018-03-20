defmodule Api.SubmitScore do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    # parse request
    req_data = Poison.decode!(req.body)

    # extract user id and track id from url
    [_, entry_id] = req.path

    # TODO: submit replay file to be valiated/stored and ensure its valid/not hacked

    # create entry for db from replay file values
    replay = compile()
    play = gen_play_entry(replay.score, replay.mods, replay.accuracy)

    # fetch the entry object from the db
    play_list =
      state.score_db
      |> Couchdb.Connector.Reader.get(entry_id)
      |> extract_plays()

    # append new play entry to array of play entries (performant way)
    new_play_array =
      [play | play_list["entries"]]
      |> List.flatten()

    # update play list to have new entries list
    Map.put(play_list, "entries", new_play_array)

    # push to db
    Couchdb.Connector.Writer.create(state.track_db, new_entries, entry_id)

    # send okay response
    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body("{\"s\": \"ok\"}")
  end

  def gen_play_entry(score, mods, accuracy) do
    %{
      score: score,
      mods: mods,
      accuracy: acc,
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
