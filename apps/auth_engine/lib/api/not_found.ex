defmodule Api.NotFound do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(_, _state) do
    response(:ok)
    |> set_header("content-type", "text/plain")
    |> set_body("""
     _____     ______     ______   ______   ______
    /\\  __-.  /\\  __ \\   /\\__  _\\ /\\__  _\\ /\\  __ \\
    \\ \\ \\/\\ \\ \\ \\ \\/\\ \\  \\/_/\\ \\/ \\/_/\\ \\/ \\ \\ \\/\\ \\
     \\ \\____-  \\ \\_____\\    \\ \\_\\    \\ \\_\\  \\ \\_____\\
      \\/____/   \\/_____/     \\/_/     \\/_/   \\/_____/
       404 - Not found. You sure that link is right?
    """)
  end
end
