# separate draw/discard into two separate decks
# add push/pop shift/unshift as primary operations (each taking one or more items)

class Deck

  def initialize(cards=[])
    srand
    @cards = cards
  end

  def pop(count=1)
    popped_cards = []
    count.times do
      popped_cards << @cards.pop
    end
    popped_cards
  end

  def push(cards)
    [*cards].each do |card|
      @cards.push(card)
    end
    cards
  end

  def shuffle
    @cards = @cards.sort_by {|x,y| rand(2) - 1}
  end

end

p deck = Deck.new([1,2,3])
p deck.shuffle
p hand = deck.pop(2)
p deck.push(hand.pop)

class LegacyDeck

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

#deck = Deck.new
#p deck.draw(5)
