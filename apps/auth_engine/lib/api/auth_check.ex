defmodule Api.AuthCheck do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, user_id, access_token] = req.path

    # lookup user
    {status, user_lookup} =
      state.db
      |> Couchdb.Connector.Reader.get(user_id)

    if status == :ok do
      # if the user was found, verify auth
      user = Poison.decode!(user_lookup)

      # verify auth and respond if it's good or not as status
      if user["auth"] == access_token do
        response(:ok)
        |> set_header("content-type", "application/json")
        |> set_body("{\"s\": \"ok\"}")
      else
        response(:ok)
        |> set_header("content-type", "application/json")
        |> set_body("{\"s\": \"foul\"}")
      end
    else
      # respond with foul
      response(:ok)
      |> set_header("content-type", "application/json")
      |> set_body("{\"s\": \"foul\"}")
    end
  end
end
