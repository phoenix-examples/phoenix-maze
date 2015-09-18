defmodule HelloPhoenix.MazeChannel do
    use Phoenix.Channel

    def join("maze:lobby", auth_msg, socket) do
        {:ok, socket}
    end

    def join("maze:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in("move_player", %{"playerId" => playerId, "posX" => posX, "posY" => posY, "style" => style}, socket) do
        broadcast! socket, "move_player", %{playerId: playerId, posX: posX, posY: posY, style: style}
        {:noreply, socket}
    end

    def handle_out("move_player", payload, socket) do 
        push socket, "move_player", payload
        {:noreply, socket}
    end

end
