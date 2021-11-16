# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'mocha'

require 'minitest/autorun'
require 'mocha/minitest'

require 'shoulda-context'

require 'midi-communications-macos'

module TestHelper
  extend self

  def device
    @device ||= select_devices
  end

  def select_devices
    @device ||= {}
    { input: MIDICommunicationsMacOS::Source.all,
      output: MIDICommunicationsMacOS::Destination.all }.each do |type, devs|

      puts ''
      puts "select an #{type.to_s}..."
      while @device[type].nil?
        devs.each do |device|
          puts "#{device.id}: #{device.name}"
        end
        selection = $stdin.gets.chomp

        next unless selection != ''

        selection = selection.to_i
        @device[type] = devs.find { |d| d.id == selection }
        puts "selected #{selection} for #{type.to_s}" unless @device[type]
      end
    end
    @device
  end

  def bytestrs_to_ints(arr)
    data = arr.map { |m| m[:data] }.join
    output = []
    until (bytestr = data.slice!(0, 2)).eql?('')
      output << bytestr.hex
    end
    output
  end

  # some MIDI messages
  VariousMIDIMessages = [
    [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], # SysEx
    [0x90, 100, 100], # note on
    [0x90, 43, 100], # note on
    [0x90, 76, 100], # note on
    [0x90, 60, 100], # note on
    [0x80, 100, 100] # note off
  ].freeze

  # some MIDI messages
  VariousMIDIByteStrMessages = [
    'F04110421240007F0041F7', # SysEx
    '906440', # note on
    '804340' # note off
  ].freeze

end

TestHelper.select_devices
