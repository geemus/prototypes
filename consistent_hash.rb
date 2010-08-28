require 'digest/sha1'

@circle = {}

def hash_key(value)
  Digest::SHA1.hexdigest(value)[0..9]
end

server = 'localhost'
100.times do |index|
  key = hash_key("server#{index}")
  @circle[key] = server
end

@keys = @circle.keys.sort

p @keys

def lookup(value)
  key = hash_key(value)
  first, last = 0, @keys.length
  while first < last
    middle = first + ((last - first) / 2)
    if @keys[middle] < key
      first = middle + 1
    else
      last = middle
    end
  end
  target = @keys[last]
  p "#{key} => #{target} => #{@circle[target]}"
end

lookup('foo')
lookup('bar')
lookup('baz')
lookup('server1')
