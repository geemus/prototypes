class Deck

  def initialize
    srand
    @discard = []
    @draw = []
    ['Clubs', 'Diamonds', 'Hearts', 'Spades'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |value|
        @discard << "#{value} of #{suit}"
      end
    end
    shuffle
  end

  def shuffle
    @draw += @discard.sort_by {|x,y| rand(2) - 1}
  end

  def discard(card)
    @discard << card
    @discard
  end

  def draw(number)
    hand = []
    number.times do |x|
      hand << @draw.pop
    end
    hand
  end

end

deck = Deck.new
p deck.draw(5)