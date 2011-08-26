#!/usr/bin/env ruby
#
# ffi-coremidi
# Realtime MIDI IO with Ruby for OSX
# (c)2011 Ari Russo
# 
require 'ffi'

require 'coremidi/device'
require 'coremidi/endpoint'
require 'coremidi/input'
require 'coremidi/map'
require 'coremidi/output'

module CoreMIDI
  VERSION = "0.1.0"
end
