# ? charge for each sale (percentage or flat?)
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
    @inventory = {}
    for key, value in attributes
      send("#{key}=", value)
    end
  end

  def buy(offer)
    free_space = self.capacity - self.inventory.values.inject(0) {|sum, value| sum + value}
    if offer.quantity > free_space
      raise "not enough capacity"
    elsif offer.price > self.capital
      raise "not enough capital"
    else
      self.inventory[offer.name] ||= 0
      self.inventory[offer.name] += offer.quantity
      self.capital -= offer.price
    end
  end

  def revoke(offer)
    if self.inventory.values.inject(0) {|sum, value| sum + value} + offer.quantity > self.capacity
      raise "not enough capacity"
    else
      self.inventory[offer.name] ||= 0
      self.inventory[offer.name] += offer.quantity
    end
  end

  def sell(name, price, quantity)
    if self.inventory[name] < quantity
      raise "not enough #{name}"
    else
      self.inventory[name] -= quantity
      Offer.new(:name => name, :price => price, :quantity => quantity)
    end
  end

end

p bronze = Offer.new(:name => :bronze, :price => 1, :quantity => 5)
p silver = Offer.new(:name => :silver, :price => 10, :quantity => 1)
p gold = Offer.new(:name => :gold, :price => 20, :quantity => 1)
p trader = Trader.new(:capital => 10, :capacity => 5)
trader.buy(bronze)
p trader
p offer = trader.sell(:bronze, 2, 2)
p trader
trader.revoke(offer)
p trader
