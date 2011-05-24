require 'rubygems'
require 'formatador'

srand

@exercises = {
  :abs    => [
    '10x bosu situps',
    '3x 10s leg raises',
    '2x2 turkish getups'
  ],
  :cardio => [
    '10x10 tactical lunge',
    '5x5 snatches',
    '30s jump rope',
    '30s rowing'
  ],
  :gymnastics => [
    '2x back lever',
    '2x 10s planche'
  ],
  :lower  => [
    '5x5 squat',
    '5x5 pistols',
    '5x5 calf press'
  ],
  :upper  => [
    '2x handstand pushup, 5x pull up',
    '5x push up, 10x full body row'
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
