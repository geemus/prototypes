#!/usr/bin/env ruby

STDOUT.sync = true

# pass file as argument, will list next talk and prompt to start, waits for y+enter
# file should be lines in form of "slack - email - talk"
File.read(ARGV.first).split("\n").each do |line|
  slack, _, talk = line.split(" - ")
  puts "# #{slack} - #{talk}"
  while true
    printf "GO? "
    input = STDIN.gets.strip
    if input == "y"
      break
    end
  end
  puts %{osascript #{slack} "#{talk}"}
  `osascript ./timer_slack.applescript #{slack} "#{talk}"`
end
