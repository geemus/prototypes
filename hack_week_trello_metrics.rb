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

invitees_count = 145
members = request("/1/boards/#{board_id}/members").map {|member| member["username"]}
members_count = members.count
ideas_count = request("/1/lists/#{ideas_list_id}/cards").count
experiments_cards = request("/1/lists/#{experiments_list_id}/cards")
experiments_count = experiments_cards.count

experimenters = []
experiments_cards.each do |card|
  experimenters.concat(
    request("/1/cards/#{card["id"]}/members").map {|member| member["username"]}
  )
end
experimenters.uniq!
experimenters_count = experimenters.count

#Members: #{members_count} - Experimenters: #{experimenters_count} - Potential Ideas: #{ideas_count} - Active Experiments: #{experiments_count}"

members_percent = (members_count.to_f / invitees_count.to_f * 100).round(1)
experimenters_percent = (experimenters_count.to_f / members_count.to_f * 100).round(1)
ideas_ratio = (ideas_count.to_f / members_count.to_f).round(1)

puts "#{members_count} members | #{members_percent}% of invitees"
puts "#{ideas_count} potential ideas | #{ideas_ratio} ideas per member"
puts "#{experiments_count} active experiments | #{experimenters_percent}% members active"
puts "Inactive: [#{(members - experimenters).join(", ")}]"
