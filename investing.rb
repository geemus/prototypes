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
current = total
cash = ARGV.first.to_f
total += cash

targets = {}
goals.keys.each do |key|
  targets[key] = total * goals[key]
end

diffs = {}
actuals.keys.each do |key|
  diff = targets[key] - actuals[key][:value]
  next unless diff > 0
  diffs[key] = targets[key] - actuals[key][:value]
end

max_diff = diffs.values.max
diffs.each {|k,v| diffs[k] = diffs[k] / max_diff}
diff_unit = cash / diffs.values.reduce(:+)

diffs.keys.each do |key|
  diff = diffs[key] * diff_unit
  price = actuals[key][:price]
  shares = (diff / price).floor
  cash -= shares * price
end
puts "cash remaining"
puts "$#{"%0.02f" % cash}"
puts

puts "key  value/goal = diff || shares * price = total"
diffs.keys.each do |key|
  diff = diffs[key] * diff_unit
  price, target, value = actuals[key][:price], targets[key], actuals[key][:value]
  shares = (diff / price).floor
  puts "#{key.to_s.ljust(5)} $#{"%0.02f" % value}/$#{"%0.02f" % target} = +$#{"%0.02f" % diff} || #{shares} * $#{"%0.2f" % price} = $#{"%0.2f" % (shares * price)}"
  STDIN.getch
end
