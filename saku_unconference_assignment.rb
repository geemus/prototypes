require "excon"
require "json"

def connection
  @connection ||= Excon.new(
    "https://api.trello.com"
  )
end

def request(method, path, query = {})
  query = {
    key: ENV["TRELLO_KEY"],
    token: ENV["TRELLO_TOKEN"]
  }.merge(query)
  JSON.parse(connection.request(method: method, path: path, query: query).body)
end

board_id = "ZTunu3ww" # real
# board_id = "SMrfVa2j" # scratch

lists = request(:get, "/1/boards/#{board_id}/lists/")
proposed_list_id = lists.detect {|list| list['name'] == 'Proposed'}['id']
session_list_ids = [
  lists.detect {|list| list['name'] == 'Session 1'}['id'],
  lists.detect {|list| list['name'] == 'Session 2'}['id'],
  lists.detect {|list| list['name'] == 'Session 3'}['id'],
  lists.detect {|list| list['name'] == 'Session 4'}['id']
]
overflow_list_id = lists.detect {|list| list['name'] == 'Overflow'}['id']

proposed_cards = request(:get, "/1/lists/#{proposed_list_id}/cards")
# sort by votes, reverse to get descending order
sorted_cards = proposed_cards.sort_by {|card| [card['idMembersVoted'].count, rand]}.reverse

# round robin to fill sessions
7.times do |x|
  cards = sorted_cards.shift(4)
  4.times do |y|
    request(:put, "/1/cards/#{cards[y]['id']}", { idList: session_list_ids[y] })
  end
end

# place remaining cards in overflow list
sorted_cards.each do |card|
  request(:put, "/1/cards/#{card['id']}", { idList: overflow_list_id })
end

puts "#{Time.now}"
