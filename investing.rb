require 'io/console'

actuals = {}
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
  actuals[symbol.to_sym] = { price: price.to_f, value: value.to_f }
end

cash = ARGV.first.to_f

puts
puts "current + cash = new total"
puts "$#{"%0.02f" % total} + $#{"%0.02f" % cash} = $#{"%0.02f" % (total + cash)}"
puts
total += cash

targets = {}
goals.keys.each do |key|
  targets[key] = total * goals[key]
end

puts "key total = current + shares * price"
actuals.keys.each do |key|
  price, value = actuals[key][:price], actuals[key][:value]
  target = targets[key]
  diff = target - value
  shares = (diff / price).round
  cash -= shares * price
  puts "#{key.to_s.ljust(5)} $#{"%0.02f" % target} = $#{"%0.02f" % value} + $#{"%0.02f" % diff} => #{shares} * $#{"%0.2f" % price}"
  STDIN.getch
end
puts

puts "cash remaining"
puts "$#{"%0.02f" % cash}"
puts
