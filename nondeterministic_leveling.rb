srand

class Level

  attr_accessor :current, :name, :successes

  def initialize(attributes = {})
    @current    = attributes[:current]    || 1
    @name       = attributes[:name]
    @parents    = attributes[:parents]    || []
    @successes  = attributes[:successes]  || 0
  end

  def inspect
    probability = if successes < current
      0.0
    else
      @current.to_f / (@successes.to_f + 1.0)
    end
    probability = (1.0 - probability) * 100
    "#{self.class} (#{@name})  #{@current.to_s.rjust(2," ")}  +#{@successes.to_s.rjust(2," ")}  #{probability.round(2).to_s.ljust(4,"0")}%"
  end

  def success!
    @successes += 1
    if rand > (@current.to_f / @successes.to_f)
      puts(self.inspect)
      @current    += 1
      @successes  = 0
      @parents.each {|parent| parent.success!}
    end
  end

  # based on chance that NEXT success will level
  def rgb
    value = if successes < current
      0
    else
      (255.0 * (@current.to_f / (successes.to_f + 1.0))).round
    end
    red   = (255 - value).to_s(16).ljust(2, "0")
    green = value.to_s(16).rjust(2, "0")
    blue  = 0.to_s(16).rjust(2, "0")
    "" << red << green << blue
  end
end

o_level = Level.new(name: "o_")

a_level = Level.new(name: "a_", parents: [o_level])
as = {
  a: Level.new(name: "aa", parents: [a_level]),
  b: Level.new(name: "ab", parents: [a_level]),
  c: Level.new(name: "ac", parents: [a_level])
}

b_level = Level.new(name: "b_", parents: [o_level])
bs = {
  a: Level.new(name: "ba", parents: [b_level]),
  b: Level.new(name: "bb", parents: [b_level]),
  c: Level.new(name: "bc", parents: [b_level])
}

c_level = Level.new(name: "c_", parents: [o_level])
cs = {
  a: Level.new(name: "ca", parents: [c_level]),
  b: Level.new(name: "cb", parents: [c_level]),
  c: Level.new(name: "cc", parents: [c_level])
}

1000.times do
  as.each {|k,v| v.success!}
  bs.each {|k,v| v.success!}
  cs.each {|k,v| v.success!}
end

puts
puts o_level.inspect
puts a_level.inspect
as.each { |k,v| puts v.inspect }
puts b_level.inspect
bs.each { |k,v| puts v.inspect }
puts c_level.inspect
cs.each { |k,v| puts v.inspect }