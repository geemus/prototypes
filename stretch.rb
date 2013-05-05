require 'open3'

STDOUT.sync = true
srand

def say(string)
  if !`which say`.empty?
    `say -v victoria #{string}`
  elsif !`which espeak`.empty?
    Open3.capture3("espeak #{string} &>/dev/null")
  else
    puts("Unknown speak synthesizer (neither `espeak` nor `say` is available).")
  end
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

stretches = [
  ["bridge",   40],
  ["l-seat",   10],
  ["l-seat",   10],
  ["twist",    45],
  ["twist",    45],
  ["pike",    120],
  ["left",    150],
  ["right",   150],
  ["middle",  150]
]
#stretches(stretches)

trifecta = [
  ["bridge", 30],
  ["l-seat", 30],
  ["twist",  30],
  ["twist",  30]
]
stretches(trifecta)
