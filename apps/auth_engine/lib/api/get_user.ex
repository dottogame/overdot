defmodule Api.GetUser do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, id] = req.path

    user_data =
      state.db
      |> Couchdb.Connector.Reader.get(id)
      |> sensor_user()
      |> Poison.encode!()

    response(:ok)
    |> set_header("content-type", "application/json")
    |> set_body(user_data)
  end

  def sensor_user(user_lookup) do
    {status, user} = user_lookup
    user = Poison.decode!(user)

    if status === :ok do
      %{
        pic: user["pic"]
      }
    else
      %{}
    end
  end
end
