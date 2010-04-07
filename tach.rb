# TODO: add tachs above tach, allows setting describes/counts that are default but can be over-ridden?

require 'rubygems'
require 'formatador'

def run_in_thread(name, count, benchmark)
  thread = Thread.new {
    thread_start = Time.now
    Formatador.display_line(name)
    Formatador.redisplay_progressbar(0, count, :started_at => thread_start)
    count.times do |index|
      tach_start = Time.now
      instance_eval(&benchmark)
      tach_elapsed = Time.now.to_f - tach_start.to_f
      Thread.current[:results] ||= []
      Thread.current[:results] << tach_elapsed
      Formatador.redisplay_progressbar(index + 1, count, :started_at => thread_start)
    end
  }
  thread.join
  thread[:results]
end

@benchmarks = []
def tach(name, count = 1, &block)
  @benchmarks << [name, count, block]
end

require 'uri'

srand

tach('first', 4) do
  sleep(rand)
end

tach('second', 4) do
  sleep(rand)
end

@names = []
@results = {}
@benchmarks.each do |name, count, benchmark|
  @names << name
  @results[name] = run_in_thread(name, count, benchmark)
end

data = []
@names.each do |name|
  value = @results[name]
  total = value.inject(0) {|sum,item| sum + item}
  data << { :average => format("%.5f", (total / value.length)), :tach => name, :total => format("%.5f", total) }
end

Formatador.display_table(data, [:tach, :average, :total])
