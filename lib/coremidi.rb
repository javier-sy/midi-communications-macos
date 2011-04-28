#!/usr/bin/env ruby
#
# This library began with coremidi binding code by
#
# * Colin Harris -- http://github.com/aberant
#
# contained in {his fork of MIDIator}[http://github.com/aberant/midiator]
#
# {MIDIator}[http://github.com/bleything/midiator] was originally authored by
#
# * Ben Bleything -- ben@bleything.net
# * Topher Cyll -- http://www.cyll.org
#
# in 2008 and released under the MIT license (see LICENSE.midiator and LICENSE.prp)
#
#
require 'ffi'

require 'coremidi/device'
require 'coremidi/entity'
require 'coremidi/input'
require 'coremidi/map'
require 'coremidi/output'

module CoreMIDI
  VERSION = "0.0.1"
end
