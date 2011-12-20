STDOUT.sync = true
srand

def say(string)
  `say -v victoria #{string}`
end

def stretches(stretches)
  say('breeth')
  print("\n")
  name_length = stretches.keys.map {|name| name.length + 1}.max # 1 == :
  print("\r  #{'stretch:'.ljust(name_length)} \e[100m \e[0m\e[37m\e[47m#{'*' * 60}\e[0m\e[100m \e[0m\n")
  stretches.keys.sort_by { rand }.each do |name|
    duration = stretches[name]
    say(name)
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
  'bridge'        => 60,
  'left split'    => 120,
  'middle split'  => 120,
  'pancake split' => 120,
  'pike'          => 120,
  'right split'   => 120
})
