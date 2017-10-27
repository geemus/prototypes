#!/usr/bin/env ruby

data = Hash.new {|h,k| h[k] = []}
File.read(ARGV.first).split("\r\n").each do |line|
  email, talk = line.split(",")
  if email == "your-email@salesforce.com"
    next
  else
    data[email] << talk
  end
end

result = {}
data.keys.sample(8).each do |speaker|
  result[speaker] = data[speaker].sample
end
result.each do |email,talk|
  puts "#{email} - #{talk}"
end
