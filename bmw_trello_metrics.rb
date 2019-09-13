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

board_id = "adK1aOmP"

members = request("/1/boards/#{board_id}/members").map {|member| member["username"]}
members_count = members.count

cards = request("/1/boards/#{board_id}/cards")
cards_count = cards.count

creators = []
board_actions = request(
    "/1/boards/#{board_id}/actions",
    {
      filter: "createCard"
    }
  )
board_actions.each do |action|
  creators << action["memberCreator"]["username"]
end
creators.uniq!
creators_count = creators.count

joiners = []
cards.each do |card|
  joiners.concat(
    request("/1/cards/#{card["id"]}/members").map {|member| member["username"]}
  )
end
joiners.uniq!
joiners_count = joiners.count

uncommitted_members = members - joiners
#members_percent = (members.count.to_f / invitees_count.to_f * 100).round(1)
joiners_percent = (joiners_count.to_f / members_count.to_f * 100).round(1)
cards_ratio = (cards_count.to_f / members_count.to_f).round(1)

puts "#{members_count} board members"
puts "#{cards_count} cards from #{creators_count} members | #{cards_ratio} ideas per member"
puts "#{joiners_count} members joined cards | #{joiners_percent}% board members"
puts "#{uncommitted_members.count} Uncommitted Board Members: [#{uncommitted_members.join(", ")}]"
