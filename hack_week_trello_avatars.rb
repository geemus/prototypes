require "excon"
require "fileutils"
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

card_id = ARGV.first
card_name = request("/1/cards/#{card_id}")["name"]
avatar_dir = File.expand_path("~/Downloads/hack_week_trello_avatars/#{card_name}")
FileUtils.mkdir_p(avatar_dir)

avatars = {}

request("/1/cards/#{card_id}/members").each do |member|
  avatars[member["username"]] = member["avatarHash"]
end

puts "#{card_name} members: [#{avatars.keys.join(", ")}]"

avatars.each do |username, hash|
  if hash
    puts "fetching #{username} avatar..."
    response = Excon.get("https://trello-avatars.s3.amazonaws.com/#{hash}/170.png")
    File.open("#{avatar_dir}/#{username}.png", "w") {|file| file.write(response.body)}
  else
    puts "skipping #{username}, no avatar specified"
  end
end

puts "done"
