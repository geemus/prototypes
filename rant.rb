require 'rubygems'
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

  def initialize(device = '/dev/tty.usbserial-A800ekni')
    @port = SerialPort.new('/dev/tty.usbserial-A800ekni', 4800, 8, 1, SerialPort::NONE)
  end

  def send_message(type, data)
    p type
    message = ""
    message << 0xA4.chr # SYNC
    message << data.length
    message << MESSAGES[type].chr
    message << [*data].map {|x| x.chr}.join

    checksum = message[0]
    1.upto(message.length - 1) do |i|
      checksum ^= message[i]
    end
    message << checksum.chr

    @port.print(message)
  end

  def receive_message
    @port.getc # SYNC
    length = @port.getc
    type = @port.getc
    data = []
    length.times do |x|
      data << @port.getc
    end
    checksum = @port.getc
    if data == [0x0, 0x1, 0x2]
    elsif type == 0x4E
      offset = data[-2]
      heartrate = data[-1]
      puts "offset => #{offset}, heartrate => #{heartrate}"
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

rant = Rant.new

##################################################

# GARMIN

rant.send_message(:system_reset, [0x00])
sleep(0.5)

rant.send_message(:request_message, [0x00, Rant::MESSAGES[:capabilities]])
rant.receive_message

# channel number, channel type, network number
rant.send_message(:assign_channel, [0x00, 0x00, 0x00])
rant.receive_message

rant.send_message(:set_network_key, [0x00, 0xb9, 0xa5, 0x21, 0xfb, 0xbd, 0x72, 0xc3, 0x45])
rant.receive_message

# channel number, device number, device number, device type id, transmission type
rant.send_message(:set_channel_id, [0x00, 0x00, 0x00, 0x78, 0x00])
rant.receive_message

rant.send_message(:set_channel_period, [0x00, 0x1F, 0x86])
rant.receive_message

rant.send_message(:set_channel_search_timeout, [0x00, 0xFF])
rant.receive_message

rant.send_message(:set_channel_rf_freq, [0x00, 0x39])
rant.receive_message

rant.send_message(:open_channel, [0x00])
rant.receive_message

##################################################

# SUUNTO
# see http://www.esl.fim.uni-passau.de/~fleitl/doc/crnt-daily/SuuntoReader_8h_source.html
# see http://www.esl.fim.uni-passau.de/~fleitl/doc/crnt-daily/SuuntoReader_8cpp_source.html

# rant.send_message(:system_reset, [0x00])
# sleep(0.5)
#
# # channel number, channel type, network number
# rant.send_message(:assign_channel, [0x00, 0x00, 0x00])
# rant.receive_message
#
# # channel number, device number, device number, device type id, transmission type
# rant.send_message(:set_channel_id, [0x00, 0x00, 0x00, 0x84, 0x00])
# rant.receive_message
#
# rant.send_message(:set_channel_period, [0x00, 0x19, 0x9A])
# rant.receive_message
#
# rant.send_message(:set_channel_rf_freq, [0x00, 0x41])
# rant.receive_message
#
# #rant.send_message(:set_channel_search_timeout, [0x00, 0xFF])
# #rant.receive_message
#
# rant.send_message(:open_channel, [0x00])
# rant.receive_message

while true
  rant.receive_message
end

rant.close
