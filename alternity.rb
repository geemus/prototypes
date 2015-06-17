# simple implementation of alternity skill checks
# see also: https://en.wikipedia.org/wiki/Alternity
# see also: http://digitalbusker.net/alpha-colony/
srand

def d(sides)
  1 + rand(sides)
end

# unskilled target:         1/2 related stat
# broad skilled target:     related stat for broad skill, but with +1 to modifier
# specialty skilled target: related stat + skill rank
# modifier -5..7
# lower is better/easier
def check(target, modifier)
  control = d(20)
  situation = case modifier
  when -5 # No Sweat
    -d(20)
  when -4 # Cakewalk
    -d(12)
  when -3 # Extremely Easy
    -d(8)
  when -2 # Very Easy
    -d(6)
  when -1 # Easy
    -d(4)
  when 0  # Average
    0
  when 1  # Tough
    d(4)
  when 2  # Hard
    d(6)
  when 3  # Challenging
    d(8)
  when 4  # Formidable
    d(12)
  when 5  # Grueling
    d(20)
  when 6  # Gargantuan
    d(20) + d(20)
  when 7  # Nearly Impossible
    d(20) + d(20) + d(20)
  end

  puts "#{control} + #{situation}"

  total = control + situation
  if control == 20 # Critical Failure
    -1
  elsif total < target / 4 # Amazing Success
    3
  elsif total < target / 2 # Good Success
    2
  elsif total < target || control == 1 # Ordinary Success
    1
  else # total >= target # Nominal Failure
    0
  end
end

10.times do
  puts check(10, -2)
end
