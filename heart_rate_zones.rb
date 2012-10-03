# see also: http://en.wikipedia.org/wiki/Heart_rate

@age, @rest = 30, 60

# max based on Oakland University nonlinear equation
# HRmax = 191.5 - (0.007 X age^2)
@max = 191.5 - (0.007 * @age * @age)

# ranges calculated using Zoladz method
# THR = HRmax - zone +/- 5
#zones = [50, 40, 30, 20, 10]
#zones.length.times do |index|
#  mid = max - zones[index]
#  low, high = mid - 5, mid + 5
#  print("  Zone #{index + 1}: #{low}-#{high}\n")
#end

# target heart rate (THR) using Karvonen method
# ((HRmax - HRrest) x intensity) + HRrest
def thr(intensity)
  (((@max - @rest) * intensity) + @rest).round
end

length = 'Performance'.length
zones = [
  thr(0.5),
  'Warmup',
  thr(0.6),
  'Fitness',
  thr(0.7),
  'Endurance',
  thr(0.8),
  'Performance',
  thr(0.9),
  'Maximum',
  thr(1.0)
]
puts(zones.join(' > '))
