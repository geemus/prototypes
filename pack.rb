class Pack

  # hearthstone: common, rare, epic, legendary
  # magic: common, uncommon, rare, mythic rare
  # misc: common, uncommon, rare, super-rare (sometimes)

  # retries + slots is how many are drawn
  # slots is how many are kept
  def initialize(attributes = {})
    @retries = attributes[:retries] || 0
    @slots = attributes[:slots] || 1
    @values = []

    Array.new(@slots + @retries).map { rand }.sort.first(@slots).each do |roll|
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
    "#{@slots.to_s.rjust(2)}+#{@retries.to_s.ljust(2)} = c#{counts[:common]} u#{counts[:uncommon]} r#{counts[:rare]} e#{counts[:epic]} l#{counts[:legendary]}"
  end
end

srand
[2, 4, 8].each do |slots|
  [0, 2, 4].each do |retries|
    2.times { puts(Pack.new(retries: retries, slots: slots).inspect) }
    puts
  end
end
