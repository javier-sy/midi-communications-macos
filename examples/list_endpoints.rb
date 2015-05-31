#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

require "coremidi"
require "pp"

# This will output a big list of Endpoint objects. Endpoint objects are what's used to input
# and output MIDI messages

pp CoreMIDI::Device.all.map { |device| device.endpoints.values }.flatten
