defmodule HelloPhoenix.RawketsChannel do
    use Phoenix.Channel
    use Database

    def join("rawkets:game", auth_msg, socket) do
        {:ok, socket}
    end

    def join("rawkets:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in("5", %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do 
        Amnesia.start
        Amnesia.transaction do
            old = Player.read(i)        
            new = %{old | x: x, y: y, angle: a, showFlame: f}
            new |> Player.write
        end
        Amnesia.stop 
        broadcast! socket, "5", %{i: i, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 
        {:noreply, socket}
    end

    #in Authenticate out Authenticate_Passed
    def handle_in("9", %{"tat" => tat, "tats" => tats}, socket) do
      push socket, "7", %{val: "true"}
      {:noreply, socket}
    end 

    #in NewPlayer out...
    def handle_in("3", %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do
      #type set color
      p = %Player{id: i, name: i, x: x, y: y, angle: a, showFlame: f }

      Amnesia.start
      Amnesia.transaction do
        p |> Player.write
      end
      Amnesia.stop
      
      #send current players
      #players = decode(HelloPhoenix.Redis.q(["HGETALL", "Players"]))

      push socket, "4", %{i: i, c: "rgb(199, 68, 145)"}
      #tell everyone about new player
      broadcast! socket, "3", %{i: i, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 
    
      #tell new player about everyone
      Amnesia.start
      Amnesia.transaction do
        query_all = [id: '_']
        all_players = Player.match(query_all)
        Enum.each(all_players, fn(p) -> push socket, "3", %{i: p.name, x: p.x, y: p.y, a: p.angle, c: p.color, f: p.showFlame, n: p.name, k: p.killCount} end)
      end
      
      {:noreply, socket}
    end 


    #Redis helpers
    defp decode({:ok, :undefined}) do 
       Map.new 
    end

    defp decode(str) do
        chunks = Enum.chunk(elem(str,1),2)
        tuples = Enum.map(chunks, fn([x,y]) -> {x, Poison.decode!(y, as: HelloPhoenix.Player)} end) 
        Enum.into(tuples, %{})
    end

end
