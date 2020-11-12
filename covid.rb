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
actuals_dates = actuals.map {|a| a['date'].gsub('-','/')}.join(',')
cases = actuals.map {|a| a['cases']}.join(',')
deaths = actuals.map {|a| a['deaths']}.join(',')

metrics = data['metricsTimeseries'].last(10)
metrics_dates = metrics.map {|a| a['date'].gsub('-','/')}.join(',')
positivities = metrics.map {|a| a['testPositivityRatio'] && a['testPositivityRatio'].round(2)}.join(',')

puts "covidactnow API"
puts "ACTUALS DATES: #{actuals_dates}"
puts "CASES: #{cases}"
puts "DEATHS: #{deaths}"
puts "METRICS DATES: #{metrics_dates}"
puts "TEST POSITIVITY RATIO: #{positivities}"
