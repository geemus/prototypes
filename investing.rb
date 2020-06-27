require 'io/console'

actual = {}
goals = {
  BIV:  0.2,
  VB:   0.1,
  VIG:  0.1,
  VNQ:  0.1,
  VSS:  0.1,
  VTI:  0.2,
  VWO:  0.1,
  VXUS: 0.1
}
total = 0.0

raw = File.read(File.expand_path("~/Downloads/ofxdownload.csv"))
lines = raw.split("\n")

# strip headers
lines.shift

#Account Number,Investment Name,Symbol,Shares,Share Price,Total Value,
while !(line = lines.shift).empty?
  _, _, symbol, _, price, value = line.split(",")
  next unless goals.keys.include?(symbol.to_sym)
  total += value.to_f
  actual[symbol.to_sym] = { price: price.to_f, value: value.to_f }
end

cash = ARGV.first.to_f

puts
puts "current + cash = new total"
puts "$#{"%0.02f" % total} + $#{"%0.02f" % cash} = $#{"%0.02f" % (total + cash)}"
puts

puts "key total = current + shares * price"
total += cash
actual.keys.each do |key|
  goal = total * goals[key]
  diff = goal - actual[key][:value]
  shares = (diff / actual[key][:price]).round
  cash -= shares * actual[key][:price]
  puts "#{key.to_s.ljust(5)} $#{"%0.02f" % goal} = $#{"%0.02f" % actual[key][:value]} + $#{"%0.02f" % diff} => #{shares} * $#{"%0.2f" % actual[key][:price]}"
  STDIN.getch
end
puts

puts "cash remaining"
puts "$#{"%0.02f" % cash}"
puts
