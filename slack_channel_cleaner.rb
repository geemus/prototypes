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
    limit: 200,
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
      limit: 10,
      token: ENV['SLACK_HEROKU_CHANNEL_CLEANER']
    }
  })
  channel_response_json = JSON.parse(channel_response.body)
  messages = channel_response_json['messages']
  # messages also includes things like joins/leaves/etc, we just want actual messages
  if last_message = messages.detect {|message| message['type'] == 'message' && (!message.has_key?('subtype') || message['subtype'] == 'bot_message')}
    channels[channel['name']][:ts] = Time.at(last_message['ts'].to_f).utc
  end
  channels[channel['name']][:has_more] = channel_response_json['has_more']
end
print "[#{channels.count}]"
puts

channels.each do |key, channel|
  # skip unless the last message was more than 6 months ago or there are no messages
  next unless channel.fetch(:ts, Time.at(0.0).utc) < STALE
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

puts "#{channels.values.last[:created]} <=> #{channels.values.last[:ts]}"
puts "CURSOR: #{ARGV.first} || NEXT: #{JSON.parse(channel_list_response.body)['response_metadata']['next_cursor']}"
