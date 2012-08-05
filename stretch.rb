STDOUT.sync = true
srand

def say(string)
  `say -v victoria #{string}`
end

def stretches(stretches)
  say('breeth')
  print("\n")
  stretches = stretches.map {|name, duration| ["#{name}:", duration]}
  name_length = (stretches.map {|name, duration| name.length} + ["stretch:".length]).max
  print("\r  #{'stretch:'.rjust(name_length)} \e[47m\e[90m|\e[37m#{'*' * 60}\e[0m\e[47m\e[90m|\e[0m")
  print("\n\n")
  stretches.each do |name, duration|
    print("\r  #{name.rjust(name_length)} \e[47m\e[90m|\e[0m#{' ' * 60}\e[47m\e[90m|\e[0m")
    say(name)
    sleep(5) # pause for setup/transition
    interval = (duration.to_f / 60.0)
    60.times do |i|
      i += 1
      completed, remaining = ('*' * i), (' ' * (60 - i))
      print("\r  #{name.rjust(name_length)} \e[47m\e[90m|\e[37m#{completed}\e[0m#{remaining}\e[47m\e[90m|\e[0m")
      sleep(interval)
    end
    print("\n\n")
  end
  say('relax')
end

stretches = case ARGV.pop
when "trifecta"
  [
    ["bridge", 20],
    ["l-seat", 10],
    ["l-seat", 10],
    ["twist",  20],
    ["twist",  20]
  ]
else
  [
    ["pike",    120],
    ["left",    120],
    ["right",   120],
    ["cobbler", 120],
    ["pancake", 120],
    ["middle",  120]
  ]
end

stretches(stretches)
