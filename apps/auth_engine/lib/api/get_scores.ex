defmodule Api.GetScores do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, user_id, _, track_id] = req.path
    entry_id = Enum.join([user_id, track_id], "")

    serialized_entries =
      state.score_db
      |> Couchdb.Connector.Reader.get(entry_id)
      |> filter_scores()

    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body(serialized_entries)
  end

  def filter_scores(user_lookup) do
    {status, data} = user_lookup
    data["scores"]
  end
end
