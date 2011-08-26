#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'coremidi'

# this program selects the first midi input and sends an inspection of the first 10 messages
# messages it receives to standard out

num_messages = 10

# AlsaRawMIDI::Device.all.to_s will list your midi devices
# or amidi -l from the command line

CoreMIDI::Input.all[0].open do |input|

  $>.puts "using input: #{input.id}, #{input.name}"

  $>.puts "send some MIDI to your input now..."

  num_messages.times do
    m = input.gets
    $>.puts(m)
  end

  $>.puts "finished"

end
