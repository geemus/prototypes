module BitTorrent
  module Bencode

    def self.decode(string)
      case delimiter = string.slice!(0,1)
      when /\d/
        string.gsub!(/^(\d*):/, '')
        bytes = (delimiter << ($1 || '')).to_i
        value = ''
        bytes.times do
          char = string.slice!(0,1)
          value << char
          if char == "\\"
            value << string.slice!(0,3)
          end
        end
        value
      when 'd'
        dictionary = {}
        while true
          if key = decode(string)
            value = decode(string)
            dictionary[key] = value
          else
            break
          end
        end
        dictionary
      when 'e'
        nil
      when 'i'
        string.gsub!(/^(\d*)e/, '')
        $1.to_i
      when 'l'
        list = []
        while value = decode(string)
          list << value
        end
        list
      end
    end

    def self.encode(value)
      case value
      when Array
        'l' << value.map {|v| encode(v)}.join << 'e'
      when Integer
        'i' << value.to_s << 'e'
      when Hash
        'd' << value.keys.sort.map {|k| [encode(k), encode(value[k])].join}.join << 'e'
      when String
        value.length.to_s << ':' << value
      end
    end

  end
end

data = File.open('example.torrent').read
p BitTorrent::Bencode.decode(data)
