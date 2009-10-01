class Die

  def initialize(sides)
    srand
    @sides = sides
  end

  def roll
    rand(@sides) + 1
  end
  
end

10.times do
  p Die.new(6).roll
end