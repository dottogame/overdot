defmodule Api.SubmitScore do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    # parse request
    req_data = Poison.decode!(req.body)

    # extract user id and track id from url
    [_, user_id, _, track_id] = req.path
    entry_id = Enum.join([user_id, track_id], "")

    # fetch the entry object from the db
    entries =
      state.score_db
      |> Couchdb.Connector.Reader.get(entry_id)
      |> filter_scores()

    # TODO: validate new entry and ensure its valid/not hacked

    # add entry and serialize
    new_entries =
      [entry | entries]
      |> List.flatten()
      |> Poison.encode!()

    # push to db
    Couchdb.Connector.Writer.create(state.track_db, new_entries, entry_id)

    # send okay response
    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body("{\"s\": \"ok\"}")
  end

  def filter_scores(user_lookup) do
    {status, data} = user_lookup

    if status == :ok do
      entry_obj = Poison.decode!(data)
      entry_obj["scores"]
    else
      []
    end
  end
end
