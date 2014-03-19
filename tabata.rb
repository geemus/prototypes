# (20 on/10 off)*8

STDOUT.sync = true

def say(string)
  if !`which say`.empty?
    `say -v victoria #{string}`
  elsif !`which espeak`.empty?
    require 'open3'
    Open3.capture3("espeak #{string} &>/dev/null")
  else
    puts("Unknown speak synthesizer (neither `espeak` nor `say` is available).")
  end
end

exercises = ARGV[0] || 1
exercises.times do |exercise|
  exercise += 1 # start with 1
  puts
  print("\r  X.Y \e[47m\e[90m[\e[0m#{'+' * 20}|#{'-' * 10}\e[47m\e[90m]\e[0m")
  puts
  say('begin')
  8.times do |interval|
    interval += 1 # start with 1
    print("\r  #{exercise}.#{interval} \e[47m\e[90m[\e[0m#{' ' * 20}|#{' ' * 10}\e[47m\e[90m]\e[0m")
    on_start = Time.now.to_f
    say('on')
    20.times do |activity|
      activity += 1
      activity_progress = "#{'+' * activity}#{' ' * (20 - activity)}"
      print("\r  #{exercise}.#{interval} \e[47m\e[90m[\e[0m#{activity_progress}|#{' ' * 10}\e[47m\e[90m]\e[0m")
      sleep(1.0)
    end
    off_start = Time.now.to_f
    say('off')
    10.times do |rest|
      rest += 1
      rest_progress = "#{'-' * rest}#{' ' * (10 - rest)}"
      print("\r  #{exercise}.#{interval} \e[47m\e[90m[\e[0m#{'+' * 20}|#{rest_progress}\e[47m\e[90m]\e[0m")
      sleep(1.0)
    end
    puts
  end
  say('end')
  puts
end
