require "excon"
require "json"

def connection
  @connection ||= Excon.new(
    "https://api.trello.com",
    query: {
      key: ENV["TRELLO_KEY"],
      token: ENV["TRELLO_TOKEN"]
    }
  )
end

def request(path)
  JSON.parse(connection.get(path: path).body)
end

board_id = "s7h2HGPk"
ideas_list_id = "5a66645e93062e9fe9582cbe"
experiments_list_id = "5a666478f1d8ff3c034f1189"

members_count = request("/1/boards/#{board_id}/members").count
ideas_count = request("/1/lists/#{ideas_list_id}/cards").count
experiments_cards = request("/1/lists/#{experiments_list_id}/cards")
experiments_count = experiments_cards.count

experimenters_count = experiments_cards.map do |card|
  request("/1/cards/#{card["id"]}/members").count
end.reduce(:+)

puts "Members: #{members_count} - Experimenters: #{experimenters_count} - Potential Ideas: #{ideas_count} - Active Experiments: #{experiments_count}"
