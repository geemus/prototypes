require 'formatador'
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

start, warned = Time.now, false

while true
  elapsed = (Time.now - start).to_i
  minutes = elapsed / 60
  if (minutes % 5 == 0)
    unless warned
      say(minutes)
      warned = true
    end
  else
    warned = false
  end
  seconds = (elapsed % 60).to_s.rjust(2, "0")
  Formatador.redisplay("#{minutes.to_s.rjust(2, "0")}:#{seconds}")
  sleep(1)
end
