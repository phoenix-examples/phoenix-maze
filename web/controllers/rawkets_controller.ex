defmodule HelloPhoenix.RawketsController do
    use HelloPhoenix.Web, :controller

    def index(conn, _params) do
        #render conn, "index.html"
        conn
        |> put_layout(false)
        |> render "index.html" 
    end
end
