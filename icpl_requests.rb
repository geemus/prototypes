require 'rubygems'
require 'excon'
require 'formatador'
require 'json'
require 'time'

KEY = File.read(File.expand_path('~/.google'))
# http://www.googleapis.com/books/v1/volumes?q=flowers&projection=lite&key=yourAPIKey

def search(query)
  connection = Excon.new('https://www.googleapis.com')
  response = connection.request(
    :method => :get,
    :path   => 'books/v1/volumes',
    :query  => {
      :key        => KEY,
      :q          => query
    }
  )
  JSON.parse(response.body)
end

Formatador.display_line
Formatador.display('query? ')
query = STDIN.gets
Formatador.display_line

results = search(query)['items'].map do |book|
  book = book['volumeInfo']
  published = Time.parse(book['publishedDate']) rescue nil
  data = {
    :authors    => book['authors'].join(', '),
    :cost       => '?',
    :isbn_13    => book['industryIdentifiers'].sort_by {|identifier| identifier['type']}.last['identifier'],
    :published  => published && published.strftime('%B %e %Y'),
    :publisher  => book['publisher'],
    :title      => [book['title'], book['subtitle']].compact.join(': ')
  }
  data
end

require 'pp'
pp results

Formatador.display_line
