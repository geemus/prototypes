require 'formatador'

STDOUT.sync = true

def say(string)
  if !`which say`.empty?
    `say -v victoria #{string}`
  elsif !`which espeak`.empty?
    Open3.capture3("espeak #{string} &>/dev/null")
  else
    puts("Unknown speak synthesizer (neither `espeak` nor `say` is available).")
  end
end

say('lightning')

start = Time.now

while true
  elapsed = (Time.now - start).to_i
  minutes = (elapsed / 60).to_s.rjust(2, "0")
  seconds = (elapsed % 60).to_s.rjust(2, "0")
  Formatador.redisplay("#{minutes}:#{seconds}  ")
  sleep(1)
  if elapsed > 300
    break
  end
end

say('thunder')
