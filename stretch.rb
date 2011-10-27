STDOUT.sync = true

def stretches(names, duration = 120)
  [*names].each do |name|
    print("#{name}:\n  ")
    `say -v victoria #{name}`
    interval = (duration.to_f / 26.0)
    26.times do |i|
      print('abcdefghijklmnopqrstuvwxyz'[i..i])
      sleep(interval)
    end
    print("\n")
  end
end

# splits, 2 minutes each
stretches(['pancake split', 'middle split', 'left split', 'right split', 'pike stretch'])

# bridge, 1 minute (for now)
stretches('bridge', 60)

`say -v victoria finish`
