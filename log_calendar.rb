require 'json'

arg = ARGV.first

path = File.expand_path("~/.logs/#{arg}")
dates = JSON.parse(File.read(path)).keys

puts "#{arg}:"
exec "ruby calendar.rb #{dates.join(' ')}"
