defmodule HelloPhoenix.RawketsChannel do
    use Phoenix.Channel
    use Database

    def join("rawkets:game", auth_msg, socket) do
        {:ok, socket}
    end

    def join("rawkets:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    #Update Player
    def handle_in("5", %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do 
        Amnesia.transaction do
            old = Player.read(i)
            if old do        
              new = %{old | x: x, y: y, angle: a, showFlame: f}
              new |> Player.write
            end
        end
        #IO.puts("update player")
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
      p = %Player{id: socket.id, name: i, x: x, y: y, angle: a, showFlame: f, color: "rgb(199, 68, 145)", killCount: 0}

      #set color
      push socket, "4", %{i: i, c: "rgb(199, 68, 145)"}

      #tell everyone about new player
      broadcast! socket, "3", %{i: socket.id, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 

      #tell new player about everyone
      Amnesia.transaction do
        selection = Player.where id != nil
        if selection do
            #IO.puts("selection")
            all_players = selection |> Amnesia.Selection.values
            Enum.each(all_players, fn(p) -> push socket, "3", %{i: p.name, x: p.x, y: p.y, a: p.angle, c: p.color, f: p.showFlame, n: p.name, k: p.killCount} end)
            #IO.puts("broadcast")
        end

        #write new player to db
        p |> Player.write
        #IO.puts("write player")
      end
      
      {:noreply, socket}
    end 

    #Create Bullet
    def handle_in("11", %{"x" => x, "y" => y, "vX" => vX, "vY" => vY}, socket) do
        b = %Bullet{id: get_current_time <> socket.id, playerId: socket.id, x: x, y: y, vX: vX, vY: vY, age: 0, alive: true}
        Amnesia.transaction do
            b |> Bullet.write
        end

        broadcast! socket, "11", %{i: b.id, x: b.x, y: b.y}
        {:noreply, socket}
    end 

    def terminate(err, socket) do
      Amnesia.transaction do
        Player.read(socket.id) |> Player.delete
      end

      broadcast! socket, "6", %{i: socket.id} 
    end

    defp get_current_time() do
        {ms, s, _} = :os.timestamp
        timestamp = (ms * 1_000_000 + s)
        to_string(timestamp)
    end
    
    #Redis helpers
    #Not using Redis using Mnesia
    defp decode({:ok, :undefined}) do 
       Map.new 
    end

    defp decode(str) do
        chunks = Enum.chunk(elem(str,1),2)
        tuples = Enum.map(chunks, fn([x,y]) -> {x, Poison.decode!(y, as: HelloPhoenix.Player)} end) 
        Enum.into(tuples, %{})
    end

end
