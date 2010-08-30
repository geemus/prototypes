require 'digest/sha1'

class Hasher

  KEY_LENGTH = 10
  SERVER_REPITITIONS = 100

  def self.hash_key(key)
    Digest::SHA1.hexdigest(key).slice(0, Hasher::KEY_LENGTH)
  end

  def initialize(servers=[])
    @circle = {}
    servers.each do |server|
      SERVER_REPITITIONS.times do |index|
        @circle[self.class.hash_key("#{server}#{index}")] = server
      end
    end
    @keys = @circle.keys.sort
  end

  def lookup(key)
    key = self.class.hash_key(key)
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

end

hasher = Hasher.new(['localhost'])

hasher.lookup('foo')
hasher.lookup('localhost1')
