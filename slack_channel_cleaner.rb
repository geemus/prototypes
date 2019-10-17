require 'excon'
require 'json'

cursor = ARGV.first
cursor = "#{cursor}=" if cursor && cursor[-1] != "="

STALE = Time.now.utc - 60 * 60 * 24 * 180 # seconds * minutes * hours * days

connection = Excon.new('https://slack.com')

channel_list_response = connection.get({
  path: 'api/conversations.list',
  query: {
    cursor: cursor,
    exclude_archived: true,
    limit: 100,
    token: ENV['SLACK_HEROKU_CHANNEL_CLEANER'],
    types: 'public_channel'
  }
})

channels = {}

JSON.parse(channel_list_response.body)['channels'].each do |channel|
  print '.'
  channels[channel['name']] = {
    id: channel['id'],
    name: channel['name'],
    num_members: channel['num_members'],
    created: Time.at(channel['created'].to_f).utc
  }
  channel_response = connection.get({
    path: 'api/conversations.history',
    query: {
      channel: channel['id'],
      limit: 1,
      token: ENV['SLACK_HEROKU_CHANNEL_CLEANER']
    }
  })
  messages = JSON.parse(channel_response.body)['messages']
  unless messages.empty?
    channels[channel['name']][:ts] = Time.at(messages.first['ts'].to_f).utc
  end
end
puts

channels.each do |key, channel|
  next unless channel.has_key?(:ts) && channel[:ts] < STALE
  next unless channel[:created] < STALE
  print "STALE <=> #{channel} <=> Archive (y/n)? "
  if $stdin.gets.strip == "y"
    archive_response = connection.post({
      path: 'api/conversations.archive',
      query: {
        channel: channel[:id],
        token: ENV['SLACK_HEROKU_CHANNEL_CLEANER']
      }
    })
    puts JSON.parse(archive_response.body)
  end
end

puts "CURSOR: #{ARGV.first} || NEXT: #{JSON.parse(channel_list_response.body)['response_metadata']['next_cursor']}"
