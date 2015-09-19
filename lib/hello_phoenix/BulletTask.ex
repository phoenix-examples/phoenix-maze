defmodule HelloPhoenix.BulletTask do

    def start_link(playerId, x, y, vX, vY) do 
        Task.start(fn -> tick(playerId, x, y, vX, vY) end)
    end

    def tick(playerId, x, y, vX, vY) do 
        bulletId = get_current_time 
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "11", %{i: bulletId, x: x, y: y} #add bullet
        :timer.sleep(30)
        tick_update(bulletId, playerId, x + vX, y + vY, 1, vX, vY)
    end

    def tick_update(bulletId, playerId, x, y, alive, vX, vY) do
        HelloPhoenix.Endpoint.broadcast! "rawkets:game", "12", %{i: bulletId, x: x, y: y} #update bullet
        :timer.sleep(30)
        if alive < 20 do 
            tick_update(bulletId, playerId, x + vX, y + vY, alive + 1, vX, vY)
        else
            HelloPhoenix.Endpoint.broadcast! "rawkets:game", "13", %{i: bulletId} #remove bullet
        end
    end

    defp get_current_time() do
        {ms, s, _} = :os.timestamp
        timestamp = (ms * 1_000_000 + s)
        to_string(timestamp)
    end

end
