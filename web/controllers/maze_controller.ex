defmodule HelloPhoenix.MazeController do 
    use HelloPhoenix.Web, :controller

    plug :put_layout, "maze.html"

    def start(conn, _params) do
        game_code = Enum.take(String.to_char_list(UUID.uuid1()),6)
        conn
        |> render("start.html", game_code: game_code)
    end

    def game(conn, %{"game_code" => game_code}) do 
        conn
        |> render("game.html", game_code: game_code)
    end
  
    def mobile(conn, _params) do
        conn
        |> put_layout("app.html")
        |> render "mobile.html" 
    end
end

