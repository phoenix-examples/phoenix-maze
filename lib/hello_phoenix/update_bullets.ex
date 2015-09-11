defmodule UpdateBullets do
  use Database

  def tick do
    Amnesia.transaction do 
        selection = Bullet.where id != nil
        if selection do
            all_bullets = selection |> Amnesia.Selection.values
            Enum.each(all_bullets, fn(b) -> update_bullet(b) end)
        end
    end

  end

  defp update_bullet(bullet) do 
    updated_bullet = %{bullet | x: bullet.x + bullet.vX, y: bullet.y + bullet.vY, age: bullet.age + 1}
    
    cond do 
      updated_bullet.age > 20 -> 
        Amnesia.transaction do
          bullet |> Bullet.delete
        end
        #Remove Bullet
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "13", %{i: bullet.id}
      true -> 
        #kill player?
        Amnesia.transaction do
          selection = Player.where alive == true
          if selection do
            alive_players = selection |> Amnesia.Selection.values
            kill_player(alive_players, updated_bullet)
          end
        end

        Amnesia.transaction do 
          updated_bullet |> Bullet.write
        end
        
        #Update Bullet
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "12", %{i: updated_bullet.id, x: updated_bullet.x, y: updated_bullet.y} 
    end
  end

  defp kill_player(players, bullet) do
      if player[0].id != bullet.id do
       kill_radius = get_kill_radius(player, bullet)
       
       cond do 
          kill_radius < 10 ->  
            HelloPhoenix.Endpoint.broadcast! "rawkets:game", "", %{i: player.id}
            updated_player = %{player | alive: false}
            Amnesia.transaction do
              updated_player |> Player.write
            end
          _ -> 
            kill_player(players[h:t], bullet)
      end
  end

  defp get_kill_radius(player, bullet) do 
    dx = bullet.x - player.x
    dy = bullet.y - player.y
    dd = (dx * dx) + (dy * dy);
    :math.sqrt(dd);
  end

end
