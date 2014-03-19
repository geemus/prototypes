require 'cgi'
require 'excon'
require 'json'
require 'uri'

address = ARGV.first

excon = Excon.new('https://maps.googleapis.com/maps/api/geocode/json')
response = excon.request(
  :method => :get,
  :query  => {
    :address  => CGI.escape(address),
    :sensor   => false
  }
)
puts JSON.pretty_generate(JSON.parse(response.body))
