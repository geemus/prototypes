class Pack

  # hearthstone: common, rare, epic, legendary
  # magic: common, uncommon, rare, mythic rare
  # misc: common, uncommon, rare, super-rare (sometimes)

  def initialize(attributes = {})
    @rolls = attributes[:rolls] || 1
    @slots = attributes[:slots] || 1
    @values = []

    @slots.times do
      roll = Array.new(@rolls).map { rand }.min
      @values << if roll > 0.33
        :common
      elsif roll > 0.13
        :uncommon
      elsif roll > 0.05
        :rare
      elsif roll > 0.01
        :epic
      else
        :legendary
      end
    end
  end

  def inspect
    counts = { common: 0, uncommon: 0, rare: 0, epic: 0, legendary: 0 }
    @values.each {|value| counts[value] += 1 }
    "#{@slots.to_s.rjust(2)} = c#{counts[:common]} u#{counts[:uncommon]} r#{counts[:rare]} e#{counts[:epic]} l#{counts[:legendary]}"
  end
end

srand
[1, 5, 10].each do |slots|
  4.times { puts(Pack.new(rolls: 1, slots: slots).inspect) }
  puts
  4.times { puts(Pack.new(rolls: 2, slots: slots).inspect) }
  puts
end
