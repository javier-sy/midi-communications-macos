#!/usr/bin/env ruby
#
# This library began with some coremidi/ffi binding code for MIDI output by
#
# * Colin Harris -- http://github.com/aberant
#
# contained in {his fork of MIDIator}[http://github.com/aberant/midiator] and a {blog post}[http://aberant.tumblr.com/post/694878119/sending-midi-sysex-with-core-midi-and-ruby-ffi]
#
# {MIDIator}[http://github.com/bleything/midiator] is (c)2008 by Ben Bleything and Topher Cyll and released under the MIT license (see LICENSE.midiator and LICENSE.prp)
#
require 'ffi'

require 'coremidi/device'
require 'coremidi/entity'
require 'coremidi/input'
require 'coremidi/map'
require 'coremidi/output'

module CoreMIDI
  VERSION = "0.0.2"
end
