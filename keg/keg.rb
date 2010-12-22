# delete is writing a special tombstone value
# merging reduces down to a single data file and single hint file
#
# class Pair
# attr_accessor :key, :value
# def self.parse (turn string into a pair)
# def read(file) (read next pair from file or return nil)
# def to_a (in memory representation)
# def to_s (in file representation)

require 'zlib'

class Keg

  def initialize(directory)
    Thread.main[:keg] ||= {}
    @directory = File.expand_path(directory)
    files = Dir.glob(File.join(@directory, '*.data.keg'))
    unless files.empty?
      @file = files.last
      File.open(@file, 'r') do |file|
        file.binmode
        while true
          data_start = file.pos
          metadata = file.read(16)
          unless metadata.nil?
            crc, data_timestamp, key_length, value_length = metadata.unpack('IIII')
            key = file.read(key_length)
            value = file.read(value_length)
            data_end = file.pos
            data_length = data_end - data_start
            memory_data = [file.path, data_length, data_start, data_timestamp]
            Thread.main[:keg][key] = memory_data
          else
            break
          end
        end
      end
    else
      @file = File.join(@directory, "#{Time.now.to_i}.data.keg")
    end
  end

  def get(key)
    if value = Thread.main[:keg][key]
      file, data_length, data_position, data_timestamp = value
      data = IO.read(file, data_length, data_position)
      # file => [crc, 32 bit int timestamp, key length, value length, key, value]
      crc, timestamp, key_length, value_length = data.unpack('IIII')
      if crc != Zlib::crc32(data[4..-1])
        raise 'crc mismatch'
      end
      key_start = 16
      key_end = key_start + key_length
      key = data[key_start...key_end]
      value_start = key_end
      value_end = value_start + value_length
      value = data[value_start...value_end]
    else
      nil
    end
  end

  def put(key, value)
    # force encoding to make sure lengths
    for thing in [key, value]
      if thing.respond_to?(:force_encoding)
        thing.force_encoding('BINARY')
      end
    end

    file = File.new(@file, 'a')
    file.flock(File::LOCK_EX)
    data_start = file.pos
    data_timestamp = Time.now
    # file => [crc, 32 bit int timestamp, key length, value length, key, value]
    file_data = [data_timestamp.to_i, key.length, value.length].pack('III')
    file_data << key
    file_data << value
    file_data = [Zlib::crc32(file_data)].pack('I') << file_data
    if file_data.respond_to?(:force_encoding)
      file_data.force_encoding('BINARY')
    end
    file.write(file_data)
    data_end = file.pos
    file.flock(File::LOCK_UN)
    file.close

    # memory => { key => [file id, value length, value position, timestamp]
    data_length = data_end - data_start
    memory_data = [@file, data_length, data_start, data_timestamp]
    # ? also write hint file
    Thread.main[:keg][key] = memory_data
  end

end

if __FILE__ == $0
  keg = Keg.new(File.expand_path('~/keg'))
  p keg.get('foo')
  p keg.put('foo', Time.now.to_i.to_s)
  p keg.get('foo')
end
