require 'formatador'

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

start, warned = Time.now, 0
interval = ARGV[0] || 1

while true
  elapsed = (Time.now - start).to_i
  minutes = elapsed / 60
  if (warned < minutes) && (minutes % interval == 0)
    say(minutes)
    warned = minutes
  end
  seconds = (elapsed % 60).to_s.rjust(2, "0")
  Formatador.redisplay("#{minutes.to_s.rjust(2, "0")}:#{seconds}")
  sleep(1)
end
