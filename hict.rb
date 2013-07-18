# see also: http://journals.lww.com/acsm-healthfitness/Fulltext/2013/05000/HIGH_INTENSITY_CIRCUIT_TRAINING_USING_BODY_WEIGHT_.5.aspx
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

exercises = [
  'jumping jacks',  # total
  'wall sit',       # lower
  'push up',        # upper
  'crunch',         # core
  'step up',        # total
  'squat',          # lower
  'dip',            # upper
  'plank',          # core
  'high knees',     # total
  'lunge',          # lower
  'push up twist',  # upper
  'side plank'      # core
]
exercise_length = exercises.map {|exercise| exercise.length}.max

circuits = ARGV[0] || 1
circuits.times do
  exercises.each do |exercise|
    start_rest = Time.now.to_f
    print("\r  #{exercise.rjust(exercise_length)} \e[47m\e[90m|\e[0m#{' ' * 60}\e[47m\e[90m|\e[0m")
    say(exercise)
    sleep(9.0 - (Time.now.to_f - start_rest)) # remaining rest interval
    say('begin')
    1.upto(30).each do |second|
      completed, remaining = (' ' * second * 2), (' ' * (60 - second * 2))
      print("\r  #{exercise.rjust(exercise_length)} \e[47m\e[90m|\e[7m#{completed}\e[0m#{remaining}\e[47m\e[90m|\e[0m")
      sleep(1)
    end
    print("\n\n")
  end
  print("\n\n")
end
