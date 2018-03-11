defmodule Api.NotFound do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _state) do
    response(:ok)
    |> set_header("content-type", "text/plain")
    |> set_body("404 - No such endpoint")
  end
end
