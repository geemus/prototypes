require 'excon'
require 'json'

query = Excon::Utils.query_string({
  query: {
    client_id:      ENV['GOOGLE_CLIENT_ID'],
    redirect_uri:   'urn:ietf:wg:oauth:2.0:oob',
    response_type:  'code',
    scope:          'https://www.googleapis.com/auth/photoslibrary.readonly'
  }
})

puts "https://accounts.google.com/o/oauth2/v2/auth#{query}"

print "code? "
code = gets

connection = Excon.new('https://www.googleapis.com')
response = connection.post(
  path: '/oauth2/v4/token',
  query: {
    code:           code,
    client_id:      ENV['GOOGLE_CLIENT_ID'],
    client_secret:  ENV['GOOGLE_CLIENT_SECRET'],
    grant_type:     'authorization_code',
    redirect_uri:   'urn:ietf:wg:oauth:2.0:oob'
  }
)
pp JSON.parse(response.body)
