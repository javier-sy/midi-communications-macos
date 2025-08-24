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

module MIDICommunicationsMacOS
end
