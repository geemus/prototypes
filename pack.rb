class Pack

  # hearthstone: common, rare, epic, legendary
  # magic: common, uncommon, rare, mythic rare
  # misc: common, uncommon, rare, super-rare (sometimes)

  def initialize(attributes = {})
    @slots = attributes[:slots] || 1
    @values = []

    @slots.times do
      x = rand
      @values << if x <= 0.01
        :legendary
      elsif x <= 0.05
        :epic
      elsif x <= 0.13
        :rare
      elsif x <= 0.33
        :uncommon
      else
        :common
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
1.upto(10).each do |slots|
  4.times { puts(Pack.new(slots: slots).inspect) }
  puts
end
