module BitTorrent
  module Bencode

    def self.decode(string)
      case delimiter = string.slice!(0,1)
      when /\d/
        bytes = delimiter.to_i
        colon = string.slice!(0,1)
        string.slice!(0, bytes)
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
