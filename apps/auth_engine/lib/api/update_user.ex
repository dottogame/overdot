defmodule Api.UpdateUser do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, id] = req.path
    user_data = Couchdb.Connector.Reader.get(state.db, id)
    user_data = Poison.decode!(elem(user_data, 1))
    req_data = Poison.decode!(req.body)

    # update account data
    data =
      user_data
      |> AuthEngine.Util.set_property("email", req_data)
      |> AuthEngine.Util.set_property("nick", req_data)
      |> AuthEngine.Util.set_property("bio", req_data)
      |> AuthEngine.Util.set_property("pass", req_data)
      |> Poison.encode!()

    # update entry in db
    Couchdb.Connector.Writer.create(state.db, data, id)

    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body("{\"s\": \"ok\"}")
  end
end
