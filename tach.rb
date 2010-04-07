require 'rubygems'
require 'formatador'

def run_in_thread(name, count, benchmark)
  thread = Thread.new {
    thread_start = Time.now
    Formatador.redisplay_progressbar(0, count, :label => name, :started_at => thread_start)
    count.times do |index|
      tach_start = Time.now
      instance_eval(&benchmark)
      tach_elapsed = Time.now.to_f - tach_start.to_f
      Thread.current[:results] ||= []
      Thread.current[:results] << tach_elapsed
      Formatador.redisplay_progressbar(index + 1, count, :label => name, :started_at => thread_start)
    end
    Formatador.display_line
  }
  thread.join
  thread[:results]
end

@benchmarks = []
@names = []
@results = {}
@times = 0

def tachs(times = 1, &block)
  @times = times
  instance_eval(&block)
  Formatador.display_line

  @benchmarks.each do |name, count, benchmark|
    @names << name
  end

  longest = @names.map {|name| name.length}.max

  @benchmarks.each do |name, count, benchmark|
    @results[name] = run_in_thread("#{name}#{' ' * (longest - name.length)}", count, benchmark)
  end

  data = []
  @names.each do |name|
    value = @results[name]
    total = value.inject(0) {|sum,item| sum + item}
    data << { :average => format("%.5f", (total / value.length)), :tach => name, :total => format("%.5f", total) }
  end

  Formatador.display_table(data, [:tach, :average, :total])
  Formatador.display_line
end

def tach(name, &block)
  @benchmarks << [name, @times, block]
end

require 'uri'

srand

tachs(4) do

  tach('first') do
    sleep(rand)
  end

  tach('second') do
    sleep(rand)
  end

end
