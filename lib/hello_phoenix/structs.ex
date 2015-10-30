defmodule HelloPhoenix.Player do

    defstruct id: "", name: "", x: 0, y: 0, angle: 0, showFlame: false, color: "", killCount: 0, alive: true

end

defmodule HelloPhoenix.Bullet do

    defstruct id: "", playerId: "", x: 0, y: 0, vX: 0, vY: 0, age: 0, alive: true

end
