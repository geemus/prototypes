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

board_id = "s7h2HGPk"
ideas_list_id = "5a66645e93062e9fe9582cbe"
experiments_list_id = "5a666478f1d8ff3c034f1189"
deferred_experiments_list_id = "5a74d8aa99ce6a58ee11c3f2"

invitees_count = 145
members = request("/1/boards/#{board_id}/members").map {|member| member["username"]}
members_count = members.count
ideas_cards = request("/1/lists/#{ideas_list_id}/cards")
experiments_cards = request("/1/lists/#{experiments_list_id}/cards")
experiments_cards.concat request("/1/lists/#{deferred_experiments_list_id}/cards")
experiments_count = experiments_cards.count
ideas_count = ideas_cards.count + experiments_cards.count

ideators = []
board_actions = request(
    "/1/boards/#{board_id}/actions",
    {
      filter: "createCard"
    }
  )
board_actions.each do |action|
  ideators << action["memberCreator"]["username"]
end
ideators.uniq!
ideators_count = ideators.count

experimenters = []
experiments_cards.each do |card|
  experimenters.concat(
    request("/1/cards/#{card["id"]}/members").map {|member| member["username"]}
  )
end
experimenters.uniq!
experimenters_count = experimenters.count

uncommitted_members = members - experimenters
members_percent = (members_count.to_f / invitees_count.to_f * 100).round(1)
experimenters_percent = (experimenters_count.to_f / members_count.to_f * 100).round(1)
ideas_ratio = (ideas_count.to_f / members_count.to_f).round(1)

puts "#{members_count} board members | #{members_percent}% of invitees"
puts "#{ideas_count} ideas from #{ideators_count} members | #{ideas_ratio} ideas per member"
puts "#{experiments_count} active experiments"
puts "#{experimenters_count} experiment members | #{experimenters_percent}% board members"
puts "#{uncommitted_members.count} Uncommitted Board Members: [#{uncommitted_members.join(", ")}]"
