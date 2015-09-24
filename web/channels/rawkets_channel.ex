defmodule HelloPhoenix.RawketsChannel do
    use Phoenix.Channel
    use Database

    @message_type_ping "1"
    @message_type_update_ping "2"
    @message_type_new_player "3"
    @message_type_set_colour "4"
    @message_type_update_player "5"
    @message_type_remove_player "6"
    @message_type_authentication_passed "7"
    @message_type_authentication_failed "8"
    @message_type_authenticate "9"
    @message_type_error "10"
    @message_type_add_bullet "11"
    @message_type_update_bullet "12"
    @message_type_remove_bullet "13"
    @message_type_kill_player "14"
    @message_type_update_kills "15"
    @message_type_revive_player "16"

    def join("rawkets:game", auth_msg, socket) do
        {:ok, socket}
    end

    def join("rawkets:" <> _private_room_id, _auth_msg, socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in(@message_type_update_player, %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do 
        #Amnesia.transaction do
        #    old = Player.read(i)
        #    if old do        
        #      new = %{old | x: x, y: y, angle: a, showFlame: f}
        #      new |> Player.write
        #    end
        #end
        #broadcast! socket, @message_type_update_player, %{i: i, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 
        
        HelloPhoenix.PlayerAgent.update(i, x, y, a, f)
        {:noreply, socket}
    end

    #in Authenticate out Authenticate_Passed
    def handle_in(@message_type_authenticate, %{"tat" => tat, "tats" => tats}, socket) do
      push socket, @message_type_authentication_passed, %{val: "true"}
      {:noreply, socket}
    end 

    #in NewPlayer out...
    def handle_in(@message_type_new_player, %{"x" => x, "y" => y, "a" => a, "f" => f, "i" => i}, socket) do
      #type set color
      p = %Player{id: socket.id, name: i, x: x, y: y, angle: a, showFlame: f, color: "rgb(199, 68, 145)", killCount: 0, alive: true}

      #set color
      push socket, @message_type_set_colour, %{i: i, c: "rgb(199, 68, 145)"}

      #tell everyone about new player
      broadcast! socket, @message_type_new_player, %{i: socket.id, x: x, y: y, a: a, c: "rgb(199, 68, 145)", f: f, n: i, k: 0} 

      #tell new player about everyone
      Amnesia.transaction do
        selection = Player.where id != nil
        if selection do
            all_players = selection |> Amnesia.Selection.values
            Enum.each(all_players, fn(p) -> push socket, @message_type_new_player, %{i: p.name, x: p.x, y: p.y, a: p.angle, c: p.color, f: p.showFlame, n: p.name, k: p.killCount} end)
        end

        #write new player to db
        #p |> Player.write
      end

      HelloPhoenix.PlayerAgent.start_link(p)
      
      {:noreply, socket}
    end 

    #Create Bullet
    def handle_in(@message_type_add_bullet, %{"x" => x, "y" => y, "vX" => vX, "vY" => vY}, socket) do
        HelloPhoenix.BulletTask.start_link(socket.id, x, y, vX, vY)
        
        {:noreply, socket}
    end 

    def handle_in(@message_type_revive_player, %{"i" => i}, socket) do 
        Amnesia.transaction do
            p = Player.read(i)
            updated_player = %{p | alive: true}
            updated_player |> Player.write
        end
        {:noreply, socket}
    end

    def terminate(err, socket) do
      Amnesia.transaction do
        Player.read(socket.id) |> Player.delete
      end

      broadcast! socket, @message_type_remove_player, %{i: socket.id} 
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
