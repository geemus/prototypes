require 'smarter_csv'

raw_data = SmarterCSV.process(
  './yes.csv',
  headers_in_file: false,
  user_provided_headers: [:email,:preferences]
)

@attendees = {}

# there were some duplicate attendees in the original data, to cleanup:
# 1. create an array of preferences for each email address
# 2. drop any nil/None preferences for simplicity
# 3. add any remaining preferences
# 4. drop any duplicate preferences for simplicity
raw_data.each do |datum|
  key = datum[:email]
  @attendees[key] ||= []
  unless [nil, 'None'].include?(datum[:preferences])
    @attendees[key].append(datum[:preferences])
    @attendees[key].uniq!
  end
end
emails = @attendees.keys.shuffle

# via: https://www.collinsdictionary.com/us/word-lists/architecture-architectural-styles
styles = %w{ baroque bauhaus brutalist byzantine classical colonial composite corinthian decorated edwardian elizabethan empire federation functionalist georgian gothic modernist mannerist moorish neoclassicist norman palladian perpendicular postmodernist regency renaissance rococo roman romanesque saracen saxon transitional tudor tuscan victorian }
styles.shuffle!

# via: https://en.wikipedia.org/wiki/Glossary_of_architecture
glossary = %w{ accolade aisle apron arcade arch articulation atrium attic baluster basement basilica belfry bracket bulwark buttress cantilever capital chancel chimney column cornice cupola dormer eave facade gable gazebo grotto keystone lintel minaret nave niche oculus parapet pavilion pier portico rotunda spire stoop truss turret wing ziggurat}
glossary.shuffle!

global_directions = %w{ fl fr cc bl br }
local_directions = %w{ fl ff fr ll cc rr bl bb br }

locations = []
global_directions.each do |gd|
  local_directions.each do |ld|
    locations << "#{gd}#{ld}"
  end
end
locations.shuffle!

total = @attendees.count
groupings = (total / 8.0).ceil

puts "#{total} attendees in #{groupings} groupings"
puts

groupings.times do
  group_name = "#{styles.pop}-#{glossary.pop}-#{locations.pop}"
  group_members = emails.pop(8)
  group_preferences = []
  group_members.each {|m| group_preferences.append(@attendees[m])}
  group_preferences.flatten!
  group_preferences.uniq!
  group_preferences.compact!
  group_preferences.each {|gp| gp.gsub!(',',' &')}

  puts "#{group_name}, #{group_members.join(', ')}, #{group_preferences.join(' && ')}"
  puts
end
