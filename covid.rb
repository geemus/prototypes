require 'excon'

TARGETS = {
  confirmed: "https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv",
  deaths: "https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_deaths_usafacts.csv"
}

TARGETS.each do |key, value|
  data = Excon.get(value).body

  if key == :confirmed
    puts "HEADERS"
    puts data.split("\r\n").first
    puts
  end

  puts key.to_s.upcase
  data.split("\r\n").each do |line|
    next unless line.include?("Johnson County,IA")
    puts line
    break
  end
  puts
end
