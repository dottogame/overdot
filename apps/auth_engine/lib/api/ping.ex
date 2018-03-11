defmodule Api.Ping do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _state) do
    response(:ok)
    |> set_header("content-type", "text/plain")
    |> set_body("pong!")
  end
end
