#
# ffi-coremidi
# Realtime MIDI IO with Ruby for OSX
#
# (c)2011-2017 Ari Russo
# https://github.com/arirusso/ffi-coremidi
#

# Libs
require "ffi"
require "forwardable"

# Modules
require "coremidi/api"
require "coremidi/endpoint"
require "coremidi/type_conversion"

# Classes
require "coremidi/entity"
require "coremidi/device"
require "coremidi/source"
require "coremidi/destination"

module CoreMIDI
  VERSION = "0.4.1"
end
