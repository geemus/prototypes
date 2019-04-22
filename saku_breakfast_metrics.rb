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

puts "Saku Breakfast"

board_id = "KuUyJYiB"

members = request("/1/boards/#{board_id}/members").map {|member| member["username"]}
puts "#{members.count} board members"

#puts request("/1/boards/#{board_id}/lists/")
wednesday_list_id = "5cb7781e07a62376beee2a3f"
wednesday_cards = request("/1/lists/#{wednesday_list_id}/cards")
thursday_list_id = "5cb778235c20096e6e3f4f15"
thursday_cards = request("/1/lists/#{thursday_list_id}/cards")

wednesday_hosts = []
wednesday_voters = []
wednesday_cards.each do |card|
  wednesday_hosts.append(*card['idMembers'])
  wednesday_voters.append(*card['idMembersVoted'])
end
puts "Wednesday: #{wednesday_hosts.count} hosts from #{wednesday_hosts.uniq.count} members, #{wednesday_voters.count} votes from #{wednesday_voters.uniq.count} voters"

thursday_hosts = []
thursday_voters = []
thursday_cards.each do |card|
  thursday_hosts.append(*card['idMembers'])
  thursday_voters.append(*card['idMembersVoted'])
end
puts "Thursday: #{thursday_hosts.count} hosts from #{thursday_hosts.uniq.count} members, #{thursday_voters.count} votes from #{thursday_voters.uniq.count} voters"

participants_count = (wednesday_hosts + wednesday_voters + thursday_hosts + thursday_voters).uniq.count
participation = ((participants_count.to_f / 285).to_f * 100).round

hosts_count = (wednesday_hosts + thursday_hosts).count
voters_count = (wednesday_voters + thursday_voters).count

puts "#{Time.now.utc.strftime('%a %b %e %k:%M')} = #{participation}% participation: #{hosts_count} hosts, #{voters_count} votes, #{participants_count} participants"
