# offers reduce inventory when made, increase it again if cancelled
#
class Offer

  attr_accessor :name, :price, :quantity

  def initialize(attributes = {})
    for key, value in attributes
      send("#{key}=", value)
    end
  end

end

class Trader

  attr_accessor :capital, :capacity, :inventory

  def initialize(attributes = {})
    @inventory = []
    for key, value in attributes
      send("#{key}=", value)
    end
  end

  def purchase(offer)
    if inventory.size + offer.quantity > capacity
      raise "not enough capacity"
    elsif offer.price > capital
      raise "not enough capital"
    else
      offer.quantity.times do |x|
        inventory << offer.name
      end
      capital = capital - offer.price
    end
  end

end

p bronze = Offer.new(:name => :bronze, :price => 1, :quantity => 5)
p silver = Offer.new(:name => :silver, :price => 10, :quantity => 1)
p gold = Offer.new(:name => :gold, :price => 20, :quantity => 1)
p trader = Trader.new(:capital => 10, :capacity => 5)
trader.purchase(bronze)
p trader
