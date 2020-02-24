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

# via: https://www.collinsdictionary.com/us/word-lists/architecture-architectural-styles
styles = %w{ baroque bauhaus brutalist byzantine classical colonial composite corinthian decorated edwardian elizabethan empire federation functionalist georgian gothic modernist mannerist moorish neoclassicist norman palladian perpendicular postmodernist regency renaissance rococo roman romanesque saracen saxon transitional tudor tuscan victorian }
styles.shuffle!

# via: https://en.wikipedia.org/wiki/Glossary_of_architecture
glossary = %w{ accolade aisle apron arcade arch articulation atrium attic baluster basement basilica belfry bracket bulwark buttress cantilever capital chancel chimney column cornice cupola dormer eave facade gable gazebo grotto keystone lintel minaret nave niche oculus parapet pavilion pier portico rotunda spire stoop truss turret wing ziggurat}
glossary.shuffle!

global = %w{ fl fr cc bl br }
local = %w{ fl ff fr ll cc rr bl bb br }

(@attendees.count / 8.0).round.times do
  puts "#{styles.pop}-#{glossary.pop}-#{global.shuffle.first}#{local.shuffle.first}"
end
