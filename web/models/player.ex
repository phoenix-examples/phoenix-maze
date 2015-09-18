defmodule HelloPhoenix.Player do
  use HelloPhoenix.Web, :model

  schema "players" do 
    field :name, :string
    field :x, :integer
    field :y, :integer
    field :angle, :integer
    field :showFlame, :boolean
    field :color, :string

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(name, x, y, angle, showFlame, color)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
  
end
