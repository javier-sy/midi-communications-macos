#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'coremidi'
require 'pp'

pp CoreMIDI::Device.all.map { |device| device.entities }