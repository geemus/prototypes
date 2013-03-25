require 'json'
require 'time'

activity, notes = ARGV.first, ARGV[1..-1].join(' ')

path = File.expand_path("~/.logs/#{activity}")

unless File.exists?(path)
  File.open(path, 'w') {|file| file.write({}.to_json)}
end

data = JSON.parse(File.read(path))

date = Time.now.strftime('%Y-%m-%d')

puts "'#{activity}': { '#{date}': '#{notes}' }"
data[date] = notes

File.open(path, 'w') {|file| file.write(data.to_json)}

exec("ruby #{File.dirname(__FILE__)}/log_calendar.rb #{activity}")
