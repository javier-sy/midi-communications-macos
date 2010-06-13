#!/usr/bin/env ruby
#
# The MIDIator driver to interact with OSX's CoreMIDI.  Taken more or less
# directly from Practical Ruby Projects.
#
# == Authors
#
# * Topher Cyll
# * Ben Bleything <ben@bleything.net>
#
# == Copyright
#
# Copyright (c) 2008 Topher Cyll
#
# This code released under the terms of the MIT license.
#

require 'ffi'

require 'midiator'
require 'midiator/driver'
require 'midiator/driver_registry'

class MIDIator::Driver::CoreMIDI < MIDIator::Driver # :nodoc:
  SnowLeopard = `uname -r` =~ /10\.\d\.\d/

  ##########################################################################
  ### S Y S T E M   I N T E R F A C E
  ##########################################################################
  module C
    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'
    attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :MIDIClientDispose, [:pointer], :int
    attach_function :MIDIGetNumberOfDestinations, [], :int
    attach_function :MIDIGetDestination, [:int], :pointer
    attach_function :MIDIOutputPortCreate, [:pointer, :pointer, :pointer], :int
    attach_function :MIDIPacketListInit, [:pointer], :pointer
    attach_function :MIDISend, [:pointer, :pointer, :pointer], :int
    if SnowLeopard
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :pointer], :pointer
    else
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :int, :pointer], :pointer
    end
  end

  module CF
    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'
    attach_function :CFStringCreateWithCString, [:pointer, :string, :int], :pointer
  end

  ##########################################################################
  ### D R I V E R   A P I
  ##########################################################################

  def open
    client_name = CF.CFStringCreateWithCString( nil, "MIDIator", 0 )

    client_ptr = FFI::MemoryPointer.new :pointer
    C.MIDIClientCreate client_name, nil, nil, client_ptr
    @client = client_ptr.read_pointer

    port_name = CF.CFStringCreateWithCString nil, "Output", 0
    outport_ptr = FFI::MemoryPointer.new :pointer
    C.MIDIOutputPortCreate @client, port_name, outport_ptr
    @outport = outport_ptr.read_pointer

    number_of_destinations = C.MIDIGetNumberOfDestinations
    raise MIDIator::NoMIDIDestinations if number_of_destinations < 1
    @destination = C.MIDIGetDestination( 0 )
  end

  def close
    C.MIDIClientDispose( @client )
  end

  def message( *args )
    format = "C" * args.size
    bytes = FFI::MemoryPointer.new FFI.type_size(:char) * args.size
    bytes.write_string args.pack(format)

    packet_list = FFI::MemoryPointer.new 256
    packet_ptr = C.MIDIPacketListInit packet_list

    if SnowLeopard
      packet_ptr = C.MIDIPacketListAdd packet_list, 256, packet_ptr, 0, args.size, bytes
    else
      # Pass in two 32-bit 0s for the 64 bit time
      packet_ptr = C.MIDIPacketListAdd packet_list, 256, packet_ptr, 0, 0, args.size, bytes
    end

    C.MIDISend( @outport, @destination, packet_list )
  end
end
