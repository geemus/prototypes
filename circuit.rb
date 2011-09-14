require 'rubygems'
require 'formatador'

srand

@exercises = {
  :core => [
    '6x bosu situps',
    '5x bicycle crunches',
    '5x crunches',
    '5x diagonal chop',
    '5x double crunch',
    '5x good morning',
    '2x2 overhead squat',
    '30s plank hold',
    '5x hanging leg raises',
    '5x supine leg raises',
    '2x 20s transverse abdominus',
    '5x v situps',
    '5x sidebends',
    '5x situp',
    '5x stiff-leg situp',
    '5x superman',
    '5x torso circle',
    '5x5 windmills'
  ],
  :cardio => [
    '10x burpees',
    '10x10 tactical lunge',
    '6x6 snatches',
    '50x jump rope',
    '30s rowing'
  ],
  :full_body => [
    '2x2 turkish getups'
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
circuit, exercises = [], []
Formatador.indent do
  while category = next_category
    options = @exercises[category]
    exercises << options[rand(options.length)]
    circuit << {
      :category => category,
      :exercise => exercises.last
    }
  end
end
Formatador.display_table(circuit)
Formatador.display_lines(['', exercises.join(', '), ''])
