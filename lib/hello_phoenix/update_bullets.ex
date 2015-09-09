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
      updated_bullet.age > 10 -> 
        Amnesia.transaction do
          bullet |> Bullet.delete
        end
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "13", %{i: bullet.id}
      true -> 
        Amnesia.transaction do 
          updated_bullet |> Bullet.write
        end
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "12", %{i: updated_bullet.id, x: updated_bullet.x, y: updated_bullet.y} 
    end

  end

end
