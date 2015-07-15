def percent(n, current = 1)
  puts current.round
  return current if n == 0
  percent(n - 1, current.to_f * 1.15)
end

percent(10, 10)
