# TODO: https://github.com/larskanis/libusb

require 'rubygems'
require 'formatador'
require 'serialport'

class Rant

  MESSAGES = {
    # Configuration
    :assign_channel             => 0x42,
    :set_channel_period         => 0x43,
    :set_channel_search_timeout => 0x44,
    :set_channel_rf_freq        => 0x45,
    :set_channel_id             => 0x51,
    :set_network_key            => 0x46,
    # Control
    :system_reset       => 0x4A,
    :open_channel       => 0x4B,
    :close_channel      => 0x4B,
    :request_message    => 0x4D,
    # Channel Event
    :channel_event => 0x40,
    # Data
    :send_broadcast_data => 0x4E,
    # Requested Response
    :capabilities => 0x54,
  }

  RESPONSES = {
    0  => :response_no_error,
    1  => :event_rx_search_timeout,
    2  => :event_rx_fail,
    3  => :event_tx,
    4  => :event_transfer_rx_failed,
    5  => :event_transfer_tx_completed,
    6  => :event_transfer_tx_failed,
    7  => :event_channel_closed,
    8  => :event_rx_fail_go_to_search,
    9  => :event_channel_collision,
    10 => :event_transfer_tx_start,
    21 => :channel_in_wrong_state,
    22 => :channel_not_opened,
    24 => :channel_id_not_set,
    25 => :lose_all_channels,
    31 => :transfer_in_progress,
    32 => :transfer_sequence_number_error,
    33 => :transfer_in_error,
    40 => :invalid_message,
    41 => :invalid_network_number,
    48 => :invalid_list_id,
    49 => :invalid_scan_tx_channel,
    64 => :nvm_full_error,
    65 => :nvm_write_error,
    112 => :usb_string_write_fail
  }

  attr_accessor :heart_beat_count, :heart_beat_intervals, :heart_beat_times, :heart_beat_rates

  def initialize(device = '/dev/tty.usbserial-A800ekni')
    @heart_beat_count, @heart_beat_intervals, @heart_beat_times, @heart_beat_rates = -1, [], [], []
    @port = SerialPort.new(device, 4800, 8, 1, SerialPort::NONE)

    # GARMIN

    send_message(:system_reset, [0x00])
    sleep(0.5)

    # channel number, channel type, network number
    send_message(:assign_channel, [0x00, 0x00, 0x00])
    receive_message

    send_message(:set_network_key, [0x00, 0xb9, 0xa5, 0x21, 0xfb, 0xbd, 0x72, 0xc3, 0x45])
    receive_message

    # channel number, device number, device number, device type id, transmission type
    send_message(:set_channel_id, [0x00, 0x00, 0x00, 0x78, 0x00])
    receive_message

    # channel period - 8070 counts (~4.06 Hz, 4 messages/second) little endian
    send_message(:set_channel_period, [0x00, 0x7c, 0x1F])
    receive_message

    send_message(:set_channel_search_timeout, [0x00, 0xFF])
    receive_message

    send_message(:set_channel_rf_freq, [0x00, 0x39])
    receive_message

    send_message(:open_channel, [0x00])
    receive_message
  end

  def send_message(type, data)
    p type
    message = ""
    message << 0xA4.chr # SYNC
    message << data.length
    message << MESSAGES[type].chr
    message << [*data].map {|x| x.chr}.join

    message_bytes = message.bytes.to_a
    checksum = message_bytes[0]
    1.upto(message_bytes.length - 1) do |i|
      checksum ^= message_bytes[i]
    end
    message << checksum.chr

    @port.print(message)
  end

  def receive_message
    @port.getbyte # SYNC
    length = @port.getbyte
    type = @port.getbyte
    data = []
    length.times do |x|
      data << @port.getbyte
    end
    checksum = @port.getbyte
    if type == 0x4E
      # account for wrapping
      count_diff = if data[-2] >= self.heart_beat_count
        data[-2] - self.heart_beat_count
      else
        255 - self.heart_beat_count + data[-2]
      end
      # skip the datapoint if it is a duplicate
      unless count_diff == 0
        self.heart_beat_count = data[-2]
        self.heart_beat_times << (data[-3] * 256) + data[-4] # data is little endian
        self.heart_beat_rates << data[-1]

        # only use consecutive beats, otherwise toss the data as too innacurate for HRV
        if count_diff == 1 && self.heart_beat_times.length > 1
          interval = self.heart_beat_times[-1] - self.heart_beat_times[-2]
          if interval < 0
            interval += 65536
          end
          interval *= 0.9765625 # 1024/1000 to convert from 1/1024 units to ms
          self.heart_beat_intervals << interval.round # round to whole ms
        end
      end
    elsif data == [0x0, 0x1, 0x2] # rx fail, can be safely ignored and are quite noisy
    elsif type == MESSAGES[:channel_event]
      channel, message_id, message_code = data
      puts "channel: #{channel}, message_id => #{message_id}, message: #{RESPONSES[message_code]}"
    else
      puts "type => #{MESSAGES.invert[type]}, length: #{length}, data: [#{data.map {|datum| "0x#{datum.to_s(16)}"}.join(', ')}], checksum: #{checksum}"
    end
  end

  def close
    @port.close
  end

end

if __FILE__ == $0

  begin

    rant = Rant.new
    start = Time.now

    STDOUT.sync=true

    while true
      rant.receive_message

      # RMSSD the square root of the mean squared difference of successive NNs
      heart_beat_intervals_ln_rmssd = if rant.heart_beat_intervals.length > 1
        ssd = 0
        (rant.heart_beat_intervals.length - 1).times do |i|
          diff = rant.heart_beat_intervals[i] - rant.heart_beat_intervals[i+1]
          ssd += diff * diff
        end
        mssd = ssd / rant.heart_beat_intervals.length.to_f
        ln_rmssd = Math.log(Math.sqrt(mssd))
        format("%0.3f", ln_rmssd)
      else
        "0.000"
      end

      heart_beat_rate = rant.heart_beat_rates.last.to_s.rjust(3, "0")

      elapsed = (Time.now - start).to_i
      minutes = (elapsed / 60).to_s.rjust(2, "0")
      seconds = (elapsed % 60).to_s.rjust(2, "0")
      count = elapsed % 12
      breathing = case count
      when 0
        '***'
      when 1
        '******'
      when 2
        '*********'
      when 3
        '************'
      when 4
        '***************'
      when 5
        '*************'
      when 6
        '**********'
      when 7
        '********'
      when 8
        '******'
      when 9
        '****'
      when 10
        '**'
      when 11
        ''
      end.ljust(17, " ")

      stretch = if elapsed < 150
        'p'
      elsif elapsed < 300
        'l'
      elsif elapsed < 450
        'r'
      elsif elapsed < 600
        'm'
      else
        'x'
      end

      data = "#{minutes}:#{seconds}  |  #{heart_beat_intervals_ln_rmssd}  |  #{heart_beat_rate}  |  #{stretch}  |  #{breathing}"
      Formatador.redisplay(data, 48)
    end

  rescue Interrupt
    rant.close
    puts
    puts("#{minutes}:#{seconds}")
    puts(rant.heart_beat_intervals.join(','))
    puts(heart_beat_intervals_ln_rmssd)
    puts(rant.heart_beat_rates.join(','))
    puts(rant.heart_beat_rates.inject(0) {|sum,rate| sum + rate} / rant.heart_beat_rates.length)
  end

end
