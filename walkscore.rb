require 'cgi'
require 'excon'
require 'json'
require 'uri'

address = ARGV.first #'314 Fairchild St, Iowa City, IA'

excon = Excon.new('https://maps.googleapis.com/maps/api/geocode/json')
response = excon.request(
  :method => :get,
  :query  => {
    :address  => CGI.escape(address),
    :sensor   => false
  }
)
location = JSON.parse(response.body)['results'].first['geometry']['location']

excon = Excon.new('http://api.walkscore.com')
response = excon.request(
  :method => :get,
  :path   => '/score',
  :query  => {
    :address  => URI.escape(address),
    :format   => 'json',
    :lat      => location['lat'],
    :lon      => location['lng'],
    :wsapikey => ENV['WALKSCORE_API_KEY']
  }
)
puts JSON.parse(response.body)
