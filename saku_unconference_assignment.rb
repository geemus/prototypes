require "excon"
require "json"

def connection
  @connection ||= Excon.new(
    "https://api.trello.com"
  )
end

def request(path, query = {})
  query = {
    key: ENV["TRELLO_KEY"],
    token: ENV["TRELLO_TOKEN"]
  }.merge(query)
  JSON.parse(connection.get(path: path, query: query).body)
end

# { id: { idMembers: [...], idMembersVoted: [...], name: "..." } }

sessions = {}

board_id = "ZTunu3ww"

#puts request("/1/boards/#{board_id}/lists/")
proposed_list_id = "5afb4079653494f2284768e3"
proposed_cards = request("/1/lists/#{proposed_list_id}/cards")

proposed_cards.each do |card|
  #next unless card['badges']['votes'] >= 3
  sessions[card['id']] = {
    idMembers:      card['idMembers'],
    idMembersVoted: card['idMembersVoted'],
    name:           card['name']
  }
end

slots = [[],[],[],[]]

# sort from most votes to least votes
sorted_keys = sessions.keys.sort_by {|key| [sessions[key][:idMembersVoted].count, rand]}.reverse
9.times do # just 9 times, as one room will be podcasting throughout
  slot_keys = sorted_keys.shift(4)
  4.times do |i|
    session = sessions[slot_keys[i]]
    slots[i] << "(#{session[:idMembersVoted].count}) #{session[:name]}"
  end
end
4.times do |i|
  puts "#{i}: #{slots[i]}"
end

puts "x: #{sessions.select {|key,value| sorted_keys.include?(key)}.map {|key, value| "(#{value[:idMembersVoted].count}) #{value[:name]}"}}"

puts "#{Time.now}"
