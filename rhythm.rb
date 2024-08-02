# frozen_string_literal: true

size = (ARGV[0] || 4).to_i
count = (ARGV[1] || 1).to_i
choices = (ARGV[2] || 'xo').split('')

groups = []

puts choices.inspect

count.times do
  group = +''
  size.times do
    group << choices.sample
  end
  groups << group
end

puts groups.join(' ')
