defmodule Api.VerifyUser do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, email, key] = req.path

    # get user id
    id =
      state.user_lookup
      |> Couchdb.Connector.Reader.get(email)
      |> AuthEngine.Util.get_id()

    {_, user} =
      state.db
      |> Couchdb.Connector.Reader.get(id)

    user_data = Poison.decode!(user)

    unless id === nil or user_data["verify"] === nil do
      if key === user_data["verify"] do
        new_user_data = Map.delete(user_data, "verify")

        {status, _, _} =
          state.db
          |> Couchdb.Connector.Writer.create(Poison.encode!(new_user_data), id)

        response(:ok)
        |> set_header("content-type", "text/plain")
        |> set_body("Verified sucessfully!")
      else
        response(:see_other)
        |> set_header("location", "/resend_verify.html")
      end
    else
      response(:see_other)
      |> set_header("location", "/resend_verify.html")
    end
  end
end
