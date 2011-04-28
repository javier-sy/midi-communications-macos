#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'coremidi'
require 'pp'

include CoreMIDI

#work here

pp Device::all.map { |d| d.entities }
