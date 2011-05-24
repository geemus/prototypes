require 'rubygems'
require 'formatador'

srand

@exercises = {
  :abs    => [
    '10x bosu situps',
    '4x leg raises',
    '2x2 turkish getups'
  ],
  :cardio => [
    '5x5 snatches',
    '30s jump rope',
    '30s rowing'
  ],
  :gymnastics => [
    '2x back lever',
    '2x planche'
  ],
  :lower  => [
    '5x5 squat',
    '5x5 pistols',
    '5x5 calf press',
    '5x5 tactical lunge'
  ],
  :upper  => [
    '2x handstand pushup, 4x pull up',
    '5x push up, 5x full body row'
  ]
}

def next_category
  @remaining_categories ||= @exercises.keys.dup.sort {|x,y| rand(2)}
  @remaining_categories.shift
end

while category = next_category
  options = @exercises[category]
  Formatador.display_line(@exercises[category][rand(options.length)])
end
