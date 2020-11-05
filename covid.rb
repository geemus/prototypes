require 'excon'
require 'json'

COUNTY = "Johnson County,IA"
FIPS = "19103"

TARGETS = {
  confirmed: "https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv",
  deaths: "https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_deaths_usafacts.csv"
}

puts "Covid Data: " << COUNTY

TARGETS.each do |key, value|
  data = Excon.get(value).body

  if key == :confirmed
    puts "DATES: " << data.split("\r\n").first.split(",").last(10).join(",")
  end

  data.split("\r\n").each do |line|
    next unless line.include?(COUNTY)
    puts "#{key.to_s.upcase}: " << line.split(",").last(10).join(",")
    break
  end
end

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
