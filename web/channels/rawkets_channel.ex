defmodule HelloPhoenix.RawketsChannel do
    use Phoenix.Channel

    def join("rawkets:game", auth_msg, socket) do
        {:ok, socket}
    end

    def join("rawkets:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in("test", %{"content" => content}, socket) do 
        {:noreply, socket}
    end

    def handle_out("test", payload, socket) do
        push socket, "test", payload
        {:noreply, socket}
    end

end
