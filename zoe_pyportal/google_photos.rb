require 'excon'
require 'json'

connection = Excon.new('https://www.googleapis.com')
response = connection.post(
  path: '/oauth2/v4/token',
  query: {
    client_id:      ENV['GOOGLE_CLIENT_ID'],
    client_secret:  ENV['GOOGLE_CLIENT_SECRET'],
    grant_type:     'refresh_token',
    refresh_token:  ENV['GOOGLE_REFRESH_TOKEN']
  }
)
access_token = JSON.parse(response.body)['access_token']

connection = Excon.new('https://photoslibrary.googleapis.com')

# list shared albums
#response = connection.get(
#  path: '/v1/sharedAlbums',
#  query: {
#    access_token: access_token
#  }
#)
#puts JSON.parse(response.body)

response = connection.post(
  body: {
    albumId: ENV['GOOGLE_PHOTOS_SHARED_ALBUM_ID'],
  }.to_json,
  path: "/v1/mediaItems:search",
  query: {
    access_token: access_token
  }
)
base_url = JSON.parse(response.body)['mediaItems'].first['baseUrl']
puts base_url + '=w320-h240'
