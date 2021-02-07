require 'excon'
require 'json'

FIPS = "19103" # Johnson County, IA

response = Excon.get(
  "https://api.covidactnow.org/v2/county/#{FIPS}.timeseries.json",
  expects: 200,
  query: { 'apiKey' => ENV['COVID_ACT_NOW'] }
)
data = JSON.parse(response.body)

actuals = data['actualsTimeseries'].last(10)
actuals_dates = actuals.map {|a| a['date'].split('-')[1,2].join('/')}.join(', ')
cases = actuals.map {|a| a['cases'].to_s.rjust(5,' ')}.join(', ')
deaths = actuals.map {|a| a['deaths'].to_s.rjust(5,' ')}.join(', ')
#vaccines = actuals.map {|a| a['vaccinationsInitiated'].to_s.rjust(5,' ')}.join(', ')
#vaccines = actuals.map {|a| a['vaccinationsCompleted'].to_s.rjust(5,' ')}.join(', ')

#metrics = data['metricsTimeseries'].last(10)
#metrics_dates = metrics.map {|a| a['date'].split('-')[1,2].join('/')}.join(', ')
#positivities = metrics.map {|a| a['testPositivityRatio'] && a['testPositivityRatio'].round(2).to_s.rjust(5,' ') || '     '}.join(', ')

puts "covidactnow API"
puts "   DATES: #{actuals_dates}"
puts "   CASES: #{cases}"
puts "  DEATHS: #{deaths}"
#puts "   DATES: #{metrics_dates}"
#puts "   RATIO: #{positivities}"
