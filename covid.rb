require 'excon'

COUNTY = "Johnson County,IA"

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
