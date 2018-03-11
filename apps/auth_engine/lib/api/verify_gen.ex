defmodule Api.VerifyGen do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    [_, _, email] = req.path

    # get user id
    id =
      state.user_lookup
      |> Couchdb.Connector.Reader.get(email)
      |> AuthEngine.Util.get_id()

    # get user data
    {_, user} =
      state.db
      |> Couchdb.Connector.Reader.get(id)

    user_data = Poison.decode!(user)

    unless id === nil or user_data["verify"] === nil do
      token = UUID.uuid4()
      new_user_data = Map.put(user_data, "verify", token)

      # send email
      AuthEngine.MailEngine.Emails.welcome_email(
        email,
        user_data["nick"],
        token
      )
      |> AuthEngine.MailEngine.Mailer.deliver_later()

      # update user data
      {status, _, _} =
        state.db
        |> Couchdb.Connector.Writer.create(Poison.encode!(new_user_data), id)

      response(:ok)
      |> set_header("content-type", "text/plain")
      |> set_body("Check your inbox; a new verification email has been sent!")
    else
      response(:see_other)
      |> set_header("location", "/resend_verify.html")
    end
  end
end
