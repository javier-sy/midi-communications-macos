#
# midi-communications-macos
# Realtime MIDI IO with Ruby for OSX
#
# (c)2021 Javier Sánchez Yeste for the modifications, licensed under LGPL 3.0 License
# (c)2011-2017 Ari Russo
#

# Libs
require 'ffi'
require 'forwardable'

# Modules
require 'midi-communications-macos/api'
require 'midi-communications-macos/endpoint'
require 'midi-communications-macos/type_conversion'

# Classes
require 'midi-communications-macos/entity'
require 'midi-communications-macos/device'
require 'midi-communications-macos/source'
require 'midi-communications-macos/destination'

require_relative 'midi-communications-macos/version'

# macOS-specific MIDI I/O using the Core MIDI framework.
#
# This library provides low-level access to MIDI devices on macOS through
# Apple's Core MIDI framework via FFI bindings. It is typically used through
# the higher-level {https://github.com/javier-sy/midi-communications midi-communications} gem.
#
# The main classes are:
# - {Source} - MIDI input endpoints for receiving messages
# - {Destination} - MIDI output endpoints for sending messages
# - {Device} - Physical or virtual MIDI devices
# - {Entity} - Logical groupings of endpoints within a device
#
# @example List all MIDI sources (inputs)
#   MIDICommunicationsMacOS::Source.all.each do |source|
#     puts "#{source.id}: #{source.display_name}"
#   end
#
# @example List all MIDI destinations (outputs)
#   MIDICommunicationsMacOS::Destination.all.each do |dest|
#     puts "#{dest.id}: #{dest.display_name}"
#   end
#
# @example Send a MIDI message
#   output = MIDICommunicationsMacOS::Destination.first
#   output.open
#   output.puts(0x90, 60, 100)  # Note On
#   output.puts(0x80, 60, 0)    # Note Off
#
# @example Receive MIDI messages
#   input = MIDICommunicationsMacOS::Source.first
#   input.open
#   messages = input.gets
#   # => [{ data: [144, 60, 100], timestamp: 1234567890.123 }]
#
# @see https://developer.apple.com/documentation/coremidi Apple Core MIDI Documentation
#
# @api public
module MIDICommunicationsMacOS
end
