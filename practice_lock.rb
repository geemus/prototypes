# frozen_string_literal: true

# MACS Chart: https://www.clksupplies.com/blogs/news/31675265-max-adjacent-cut-specification-macs
# Varies by brand: [4, 4, 5, 5, 6, 7, 7, 7, 7, 8, 8]
MACS = 4

spool_count = rand(6)
spindle_count = 6 - spool_count
driver_pins = [:spool] * spool_count + [:spindle] * spindle_count
driver_pins.shuffle!

key_pins = [(1..6).to_a.shuffle.pop]
5.times do |i|
  last = key_pins[i]
  max = [last + MACS, 6].min
  min = [1, last - MACS].max
  key_pins << min.upto(max).to_a.shuffle.pop
end

puts "MACS: #{MACS}"
puts "D-Pins: #{driver_pins.inspect}"
puts "K-Pins: #{key_pins.inspect}"
