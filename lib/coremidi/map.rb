#!/usr/bin/env ruby
module CoreMIDI

  #
  # libasound RawMIDI struct, enum and function bindings
  #
  module Map

    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

    SnowLeopard = `uname -r` =~ /10\.\d\.\d/

    module TypeAliases
      CFStringRef = :pointer
      ItemCount = :int
      MIDIObjectRef = :pointer
      OSStatus = :int
    end

    class MIDIDeviceRef < FFI::Struct
      include TypeAliases

    end

    attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :int
    attach_function :MIDIClientDispose, [:pointer], :int
    attach_function :MIDIGetNumberOfDestinations, [], TypeAliases::ItemCount
    attach_function :MIDIGetNumberOfDevices, [], TypeAliases::ItemCount
    attach_function :MIDIGetDestination, [:int], :pointer
    attach_function :MIDIGetDevice, [TypeAliases::ItemCount], MIDIDeviceRef
    # OSStatus MIDIObjectGetStringProperty (MIDIObjectRef  obj, CFStringRef propertyID, CFStringRef *str);
    attach_function :MIDIObjectGetStringProperty, [TypeAliases::MIDIObjectRef, TypeAliases::CFStringRef, :pointer], TypeAliases::OSStatus
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
      attach_function :CFStringGetCStringPtr, [:pointer, :int], :pointer
    end

  end

end
