use Amnesia
defdatabase Database do

    deftable Player
    deftable Bullet

    deftable Player, [:id, :name, :x, :y, :angle, :showFlame, :color, :killCount, :alive], type: :ordered_set, index: [:name] do
        @type t :: %Player{id: String.t, name: String.t, x: Decimal.t, y: Decimal.t, angle: Decimal.t, showFlame: Boolean.t, color: String.t, killCount: Integer.t, alive: Boolean.t}
    end

    deftable Bullet, [:id, :playerId, :x, :y, :vX, :vY, :age, :alive], type: :ordered_set, index: [:playerId] do
        @type t :: %Bullet{id: String.t, playerId: String.t, x: Decimal.t, y: Decimal.t, vX: Decimal.t, vY: Decimal.t, age: Decimal.t, alive: Boolean.t}
    end

end
