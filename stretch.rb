STDOUT.sync = true

def stretch(name, duration = 120)
  print("#{name}: ")
  `say -v victoria#{name}`
  interval = (duration.to_f / 26.0)
  26.times do |i|
    print('abcdefghijklmnopqrstuvwxyz'[i..i])
    sleep(interval)
  end
  print("\n")
end

# splits, 2 minutes each
[
  'pancake split',
  'middle split',
  'left split',
  'right split'
].each {|name| stretch(name, 120)}

# bridge, 1 minute (for now)
[
  'bridge'
].each {|name| stretch(name, 60)}
