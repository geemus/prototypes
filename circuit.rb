require 'rubygems'
require 'formatador'

srand

@exercises = {
  :abs    => [
    '6x bosu situps',
    '3x 10s leg raises',
    '2x 20s transverse abdominus',
    '2x2 turkish getups',
    '5x v situps'
  ],
  :cardio => [
    '10x burpees',
    '10x10 tactical lunge',
    '6x6 snatches',
    '50x jump rope',
    '30s rowing'
  ],
  :grip => [
    '5x gripprotrainer crush, 10x expand',
    '5x kettlebell crush, 10x expand',
    '5x kettlebell towel shrug, 10x expand',
    '5x5 sledgehammer lever',
    '5x5 sledgehammer rotation',
    '5x5 sledgehammer rotation (crimp grip)',
    '5x sledgehammer walk'
  ],
  :gymnastics => [
    'back lever',
    'l-seat',
    'planche'
  ],
  :lower  => [
    '6x6 squat',
    '4x4 pistols',
    '8x8 calf press'
  ],
  :upper_pull  => [
    '5x pull up',
#    '8x full body row'
  ],
  :upper_push  => [
    '6x clean and press',
    '2x handstand pushup',
    '8x push up',
  ]
}

def next_category
  @remaining_categories ||= @exercises.keys.dup.sort {|x,y| rand(2)}
  @remaining_categories.shift
end

Formatador.display_line
Formatador.display_line('Circuit:')
circuit = []
Formatador.indent do
  while category = next_category
    options = @exercises[category]
    circuit << {
      :category => category,
      :exercise => options[rand(options.length)]
    }
  end
end
Formatador.display_table(circuit)
Formatador.display_line
