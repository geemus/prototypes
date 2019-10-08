require 'smarter_csv'

# See Also: https://github.com/tilo/smarter_csv/tree/1.2-stable
raw_data = SmarterCSV.process('./raw.csv', keep_original_headers: true)

@groups = { '?' => { members: [], accommodations: [] } }
@group_limit = 8
@individuals = []
@runoff = []

# munge data into easier to manipulate format, like:
# before: { 'Timestamp' => '...', 'Email Address' => '...', 'What are your top five undinner topic choices? [...]', ... }
# after: { accommodations: '...', email: '...', preferences [...] }
raw_data.each do |datum|
  datum.delete('Timestamp')
  individual = {
    accommodations:   datum.delete("Any dietary accommodations?"),
    email:            datum.delete("Email Address"),
    preferences:    []
  }

  # just strip non-accomodations
  if ['n/a', 'no', 'no.', 'no. thanks.', 'none', 'nope'].include?(individual[:accommodations].to_s.downcase)
    individual[:accommodations] = nil
  end

  inverted_datum = datum.invert
  %w{1st 2nd 3rd 4th 5th}.each do |preference|
    break unless inverted_datum[preference] # skip nil
    individual[:preferences] << inverted_datum[preference].split('[').last.split(']').first
  end
  # add a fallback value, in case someone is not placed from any of their choices
  individual[:preferences] << '?'
  @individuals << individual
end

# place into highest non-full, non-runoff preference, or '?' if no preferences remain
# result: { 'topic' => { accommodations: [...], members: [...] } }
def find_placement(individual, limit_group = true) # omitting runoff topics
  individual[:preferences].each do |preference|
    # skip runoff preferences
    next if @runoff.include?(preference)
    @groups[preference] ||= { members: [], accommodations: [] }
    # add to a non-full group, or failing that, the '?' group
    if !limit_group || @groups[preference][:members].count < @group_limit || preference == '?'
      @groups[preference][:members] << individual[:email]
      @groups[preference][:accommodations] << individual[:accommodations] if individual[:accommodations]
      individual[:choice] = individual[:preferences].index(preference) + 1 # move to one-index
      return preference # individual has been grouped, so we can stop processing preferences
    end
  end
end

def execute_runoff(group_size)
  puts
  puts "Runoff groups < #{group_size}"
  while true
    group, data = @groups.select { |topic, datum|
      topic != '?' && datum[:members].size <= group_size
    }.sort_by { |topic, datum| datum[:members].size }.reverse.first
    break unless group
    @groups.delete(group)
    @runoff << group
    movers = @individuals.select { |individual| data[:members].include?(individual[:email]) }
    movers.each { |mover| find_placement(mover) }
  end
  display_group_info
end

# provide an overview of unplaced, as well as a count for each group size
def display_group_info
  counts = {}
  total = @groups['?'][:members].count
  @groups.each do |topic, datum|
    next if topic == '?'
    count = datum[:members].count
    total += count
    counts[count] ||= 0
    counts[count] += 1
  end
  data = []
  counts.keys.sort_by { |key| key.to_i }.each do |key|
    data << "#{counts[key]} #{key}s"
  end
  unplaced = (@groups['?'] && @groups['?'][:members].count) || 0
  puts "#{total} total, #{unplaced} ?s = #{data.join(', ')}"
end

puts
puts "Initial Placement"
# first pass, place each individual in their highest nonfull preference group
@individuals.each do |individual|
  find_placement(individual)
end
display_group_info

# starting with smallest, move people around until all groups are larger than 4
1.upto(4).each {|x| execute_runoff(x)}

# remove group limits and place unplaced
# breaks precedence rules, but there are very few of these
# seems good enough for our purposes
puts
puts "Moving Unplaced by raising group limit"
group = @groups['?']
@groups['?'] = { members: [], accommodations: [] }
movers = @individuals.select { |individual| group[:members].include?(individual[:email]) }
movers.each { |mover| find_placement(mover, false) }
display_group_info

if @groups['?'][:members].count == 0
  @groups.delete('?')
end

puts

# show how well we matched preferences
choices = Hash.new(0)
@individuals.each { |individual| choices[individual[:choice]] += 1 }
puts "#{choices.values.sum} total = #{choices[1]} 1st, #{choices[2]} 2nd, #{choices[3]} 3rd, #{choices[4]} 4th, #{choices[5]} 5th"

# groups: { 'topic' => { accommodations: [...], members: [...] } }
# Topic,#,...,#,accommodations,Sponsor,Restaurant,URL
max = @groups.values.map {|value| value[:members].count}.max
result = ''
headers = []
#headers.concat(['Accommodations', 'Sponsor', 'Restaurant', 'URL'])
headers.concat(['Sponsor', 'Restaurant', 'URL', 'Time', 'Accomodations'])
headers << 'Topic'
1.upto(max) {|x| headers << x.to_s}
result << headers.join("\t") << "\r\n"
@groups.each do |topic, datum|
  row = []
  row.concat(['', '', '', ''])
  row << datum[:accommodations].join(' & ')
  row << topic
  # offset to zero-indexing
  0.upto(max-1) {|x| row << datum[:members][x].to_s}
  result << row.join("\t") << "\r\n"
end

File.open('groups.tsv', 'w') { |f| f.print(result) }
