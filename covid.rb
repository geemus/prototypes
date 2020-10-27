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
  query: { 'apiKey' => ENV['COVID_ACT_NOW'] }
)
data = JSON.parse(response.body)
timeseries = data['metricsTimeseries'].last(10)
dates = timeseries.map {|a| a['date'].gsub('-','/')}.join(',')
positivities = timeseries.map {|a| a['testPositivityRatio'].round(2)}.join(',')

puts "TEST POSITIVITY"
puts "DATES: #{dates}"
puts "RATIO: #{positivities}"
