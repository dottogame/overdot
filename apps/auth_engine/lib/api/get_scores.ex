defmodule Api.GetScores do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, entry_id] = req.path

    serialized_entries =
      state.score_db
      |> Couchdb.Connector.Reader.get(entry_id)
      |> filter_scores()
      |> Poison.encode!()

    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body(serialized_entries)
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
