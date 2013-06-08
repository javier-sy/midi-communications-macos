# ffi-coremidi
# Realtime MIDI IO with Ruby for OSX
# (c)2011-2013 Ari Russo

# libs
require 'ffi'
require 'forwardable'

# modules
require 'coremidi/endpoint'
require 'coremidi/map'

# classes
require 'coremidi/entity'
require 'coremidi/device'
require 'coremidi/source'
require 'coremidi/destination'

module CoreMIDI
  VERSION = "0.2.0"
end
