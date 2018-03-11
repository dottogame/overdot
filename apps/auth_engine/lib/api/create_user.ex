defmodule Api.CreateUser do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(req, state) do
    req_data = Poison.decode!(req.body)

    # check for all needed params
    has_all = ["email", "nick", "pass"] |> Enum.all?(&Map.has_key?(req_data, &1))

    # check if email is taken
    {status, _} = Couchdb.Connector.Reader.get(state.user_lookup, req_data["email"])

    if status === :error do
      if has_all do
        # create new user
        user_id = UUID.uuid4()
        token = UUID.uuid4()

        # create link from user email to account id
        Couchdb.Connector.Writer.create(
          state.user_lookup,
          Poison.encode!(%{link: user_id}),
          req_data["email"]
        )

        # assemble account data
        data =
          %{
            "verify" => token,
            "nick" => req_data["nick"],
            "email" => req_data["email"],
            "pass" => Bcrypt.hash_pwd_salt(req_data["pass"])
          }
          |> Poison.encode!()

        # create entry in db
        Couchdb.Connector.Writer.create(state.db, data, user_id)

        # send email
        AuthEngine.MailEngine.Emails.welcome_email(
          req_data["email"],
          req_data["nick"],
          token
        )
        |> AuthEngine.MailEngine.Mailer.deliver_later()

        response(:ok)
        |> set_header("content-type", "application/json")
        |> set_body(Poison.encode!(%{s: "ok"}))
      else
        response(:ok)
        |> set_header("content-type", "application/json")
        |> set_body(Poison.encode!(%{s: "err"}))
      end
    else
      response(:ok)
      |> set_header("content-type", "application/json")
      |> set_body(Poison.encode!(%{s: "err", c: "email already registered"}))
    end
  end
end
