require 'libusb'

usb = LIBUSB::Context.new
ant = usb.devices(:idVendor => 0x0a5c, :idProduct => 0x21e6).first


