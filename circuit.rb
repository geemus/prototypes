require 'rubygems'
require 'formatador'

srand

@exercises = {
  :abs    => [
    '6x bosu situps',
    '3x 10s leg raises',
    '2x2 turkish getups',
    '5x v situps'
  ],
  :cardio => [
    '10x burpees',
    '10x10 tactical lunge',
    '6x6 snatches',
    '30s jump rope',
    '30s rowing'
  ],
  :gymnastics => [
    'back lever',
    'planche'
  ],
  :lower  => [
    '5x5 squat',
    '5x5 pistols',
    '6x6 calf press'
  ],
  :upper  => [
    '2x handstand pushup, 5x pull up',
    '6x push up, 10x full body row'
  ]
}

def next_category
  @remaining_categories ||= @exercises.keys.dup.sort {|x,y| rand(2)}
  @remaining_categories.shift
end

Formatador.display_line
Formatador.display_line('Circuit:')
Formatador.indent do
  while category = next_category
    options = @exercises[category]
    Formatador.display_line(@exercises[category][rand(options.length)])
  end
end
Formatador.display_line
