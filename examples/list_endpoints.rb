#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

require "midi-communications-macos"
require "pp"

# This will output a big list of Endpoint objects. Endpoint objects are what's used to input
# and output MIDI messages

pp MIDICommunicationsMacOS::Device.all.map { |device| device.endpoints.values }.flatten
