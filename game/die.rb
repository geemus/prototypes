class Die

  def initialize(sides)
    srand
    @sides = sides
  end

  def roll(quantity = 1)
    total = 0
    quantity.times do |i|
      total += rand(@sides) + 1
    end
    total
  end

end

10.times do
  p Die.new(6).roll
  p Die.new(6).roll(2)
end
