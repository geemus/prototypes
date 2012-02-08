STDOUT.sync = true
srand

def say(string)
  `say -v victoria #{string}`
end

def stretches(stretches)
  say('breeth')
  print("\n")
  keys = stretches.keys + ['stretch']
  name_length = keys.map {|name| "#{name}:".length}.max
  print("\r  #{'stretch:'.ljust(name_length)} \e[100m \e[0m\e[37m\e[47m#{'*' * 60}\e[0m\e[100m \e[0m\n")
  #stretches.keys.sort_by { rand }.each do |name|
  %w{bridge pike left right middle}.each do |name|
    duration = stretches[name]
    say(name)
    sleep(2) # pause for setup/transition
    interval = (duration.to_f / 60.0)
    name += ':'
    60.times do |i|
      i += 1
      completed, remaining = ('*' * i), (' ' * (60 - i))
      print("\r  #{name.ljust(name_length)} \e[100m \e[0m\e[37m\e[47m#{completed}\e[0m#{remaining}\e[100m \e[0m")
      sleep(interval)
    end
    print("\n")
  end
  print("\n")
  say('relax')
end

stretches({
  'bridge'  => 60,
  'left'    => 120,
  'middle'  => 120,
  'pike'    => 120,
  'right'   => 120
})
