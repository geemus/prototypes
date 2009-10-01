require 'benchmark'

TIMES = 1_000_000

Benchmark.bm(10) do |bench|
  bench.report('5 * 5') do
    TIMES.times do |x|
      5 * 5
    end
  end
end
