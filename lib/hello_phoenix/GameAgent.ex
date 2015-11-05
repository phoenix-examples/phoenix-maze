defmodule HelloPhoenix.GameAgent do
  
  def start_link() do
    Agent.start_link(fn -> %{players: HashDict.new(), bullets: HashDict.new()} end, name: :rawkets)
  end

  def add_player(player) do
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | players: HashDict.put(s.players, player.id, player)}} end) 
  end

  def update_player(player) do 
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | players: update_key(s.players, player.id, fn(s) -> player end)}} end)
  end

  def revive_player(playerId) do
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | players: update_key(s.players, playerId, fn(s) -> %{s | alive: true } end)}} end)
  end

  def remove_player(playerId) do
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | players: pop_key(s.players, playerId)}} end)
  end

  def add_kill(playerId) do 
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | players: update_key(s.players, playerId, fn(player) -> %{player | killCount: player.killCount + 1} end)}} end) 
  end

  def get_player(playerId) do 
    Agent.get(:rawkets, fn(s) -> HashDict.get(s.players, playerId) end)
  end

  def get_players() do 
    Agent.get(:rawkets, fn(s) -> HashDict.values(s.players) end)
  end

  def get_state() do 
    Agent.get(:rawkets, fn(s) -> s end)
  end

  def add_bullet(bullet) do 
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | bullets: HashDict.put(s.bullets, bullet.id, bullet)}} end)
  end

  def update_bullet(bullet) do 
    Agent.get_and_update(:rawkets, fn(s) -> {:ok, %{s | bullets: update_key(s.bullets, bullet.id, fn(s) -> bullet end)}} end)
  end

  def delete_bullet(bulletId) do
    Agent.get_and_update(:rawkets, fn(s) -> remove_bullet(s, bulletId) end) 
  end

  def tick() do
    all_bullets = Agent.get(:rawkets, fn(s) -> HashDict.values(s.bullets) end)
    Enum.each(all_bullets, fn(b) -> bullet_tick(b) end)
  end

  defp pop_key(dict, key) do 
    {val, ret} = HashDict.pop(dict, key)
    ret
  end

  defp update_key(dict, key, fun) do 
    try do
      HashDict.update!(dict, key, fn(s) -> fun.(s) end)
    rescue
      KeyError -> dict
    end
  end

  defp remove_bullet(game_struct, bulletId) do
    {:ok, %{game_struct | bullets: HashDict.delete(game_struct.bullets, bulletId)}}
  end

  defp bullet_tick(bullet) do 
    updated_bullet = %{bullet | x: bullet.x + bullet.vX, y: bullet.y + bullet.vY, age: bullet.age + 1}
    
    cond do 
      updated_bullet.age > 20 -> 
        delete_bullet(updated_bullet.id)
        #Remove Bullet
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "13", %{i: bullet.id}
      true -> 
        #kill player?
        alive_players = get_players() 
        kill_player(alive_players, updated_bullet)

        update_bullet(updated_bullet)
        
        #Update Bullet
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "12", %{i: updated_bullet.id, x: updated_bullet.x, y: updated_bullet.y} 
    end
  end

  defp kill_player([], bullet) do
    #nothing
  end

  defp kill_player([head|tail], bullet) do
      kill_radius = get_kill_radius(head, bullet)
    
      case {head.id == bullet.playerId, kill_radius < 10} do 
        {false, true} ->
            updated_player = %{head | alive: false}
                update_player(updated_player)
                add_kill(bullet.playerId)
                updated_killer = get_player(bullet.playerId)
                delete_bullet(bullet.id)

                HelloPhoenix.Endpoint.broadcast! "rawkets:game", "14", %{i: head.id, ik: bullet.playerId, k: updated_killer.killCount } #kill player
                HelloPhoenix.Endpoint.broadcast! "rawkets:game", "13", %{i: bullet.id} #remove bullet
        _ -> 
            kill_player(tail, bullet)
        end
  end

  defp get_kill_radius(player, bullet) do 
    dx = bullet.x - player.x
    dy = bullet.y - player.y
    dd = (dx * dx) + (dy * dy);
    :math.sqrt(dd);
  end

end
