# double checking math on strawberry tower plans
# see: https://diy.dunnlumber.com/projects/grow-your-own-strawberries
length = 24
5.times do |x|
  puts length.round(2)
  length/=2
  length = Math.sqrt(length**2 + length**2)
end
