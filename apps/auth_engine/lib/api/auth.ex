defmodule Api.Auth do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    # parse request
    req_data = Poison.decode!(req.body)

    # get user id
    id =
      state.user_lookup
      |> Couchdb.Connector.Reader.get(req_data["email"])
      |> AuthEngine.Util.get_id()

    unless id === nil do
      user =
        state.db
        |> Couchdb.Connector.Reader.get(id)
        |> get_user()
        |> Poison.decode!()

      cond do
        user["verify"] !== nil ->
          # user not verified error
          response(:ok)
          |> set_header("content-type", "application/json")
          |> set_body("{\"s\": \"err\", \"c\": \"email not verified\"}")

        Bcrypt.verify_pass(req_data["pass"], user["pass"]) ->
          # correct password (succeed)
          # update auth token
          access_token = UUID.uuid4()
          new_user = Map.put(user, "auth", access_token)
          Couchdb.Connector.Writer.create(state.db, Poison.encode!(new_user), id)

          response(:ok)
          |> set_header("content-type", "application/json")
          |> set_body(
            %{
              "s" => "ok",
              "access_token" => access_token,
              "nick" => user["nick"]
            }
            |> Poison.encode!()
          )

        true ->
          # incorrect password
          response(:ok)
          |> set_header("content-type", "application/json")
          |> set_body("{\"s\": \"err\", \"c\": \"invalid username or password\"}")
      end
    else
      # create response
      response(:ok)
      |> set_header("content-type", "application/json")
      |> set_body("{\"s\": \"err\", \"c\": \"invalid username or password\"}")
    end
  end

  def get_user(user_lookup) do
    {status, user} = user_lookup

    if status !== :ok do
      nil
    else
      user
    end
  end
end
