defmodule HelloPhoenix.RawketsChannel do
    use Phoenix.Channel

    def join("rawkets:game", auth_msg, socket) do
        {:ok, socket}
    end

    def join("rawkets:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    #in Authenticate out Authenticate_Passed
    def handle_in("9", %{"tat" => tat, "tats" => tats}, socket) do
      push socket, "7", %{val: "true"}
      {:noreply, socket}
    end 

    #in NewPlayer out...
    def handle_in("3", %{"x" => x, "y" => y, "a" => a, "f" => f, "tat" => tat, "tats" => tats}, socket) do
      #type set color
      p = %HelloPhoenix.Player{x: x, y: y, angle: a, showFlame: f }
      
      #send current players
      players = decode(HelloPhoenix.Redis.q(["HGETALL", "Players"]))

      push socket, "4", %{i: tat, c: "rgb(199, 68, 145)"}
      broadcast! socket, "3", %{i: tat, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: "test", k: 1} 
      {:noreply, socket}
    end 



    defp decode({:ok, :undefined}) do 
       Map.new 
    end

    defp decode(str) do
        chunks = Enum.chunk(elem(str,1),2)
        tuples = Enum.map(chunks, fn([x,y]) -> {x, Poison.decode!(y, as: HelloPhoenix.Player)} end) 
        Enum.into(tuples, %{})
    end

end
