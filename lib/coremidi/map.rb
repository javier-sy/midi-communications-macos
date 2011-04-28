#!/usr/bin/env ruby
module CoreMIDI

  #
  # libasound RawMIDI struct, enum and function bindings
  #
  module Map

    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/Map.framework/Versions/Current/Map'

    SnowLeopard = `uname -r` =~ /10\.\d\.\d/

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

    module CF
      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'
      attach_function :CFStringCreateWithCString, [:pointer, :string, :int], :pointer
    end

  end

end
