defmodule HelloPhoenix.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "maze:*", HelloPhoenix.MazeChannel
  channel "rawkets:*", HelloPhoenix.RawketsChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  # {:ok, assign(socket, :user_id, )}
  #
  #  To deny connection, return `:error`.
  def connect(_params, socket) do
    #{:ok, socket}
    {:ok, assign(socket, :user_id, _params["user_id"])}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  # def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     MyApp.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # def id(_socket), do: nil
  def id(_socket), do: "users_socket:#{_socket.assigns.user_id}"
  
end
