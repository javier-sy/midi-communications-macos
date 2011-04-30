#!/usr/bin/env ruby

module CoreMIDI

  #
  # coremidi struct, enum and function bindings
  #
  # Some comments from from "Mac OS X Developer Library", Apple Computer, Inc.
  # https://developer.apple.com
  #
  module Map

    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

    SnowLeopard = `uname -r` =~ /10\.\d\.\d/

    module TypeAliases
      CFStringRef = :pointer
      ItemCount = :int
      MIDIDeviceRef = :pointer
      MIDIEndpointRef = :pointer
      MIDIEntityRef = :pointer
      MIDIObjectRef = :pointer
      OSStatus = :int
    end

    callback :sysex_output_callback, [:pointer], :void

    # This represents a request to send a single system-exclusive MIDI event to a MIDI destination asynchronously.
    class MIDISysexSendRequest < FFI::Struct

             # The endpoint to which the event is to be sent.
      layout :destination,         TypeAliases::MIDIEndpointRef,
             # Initially, a pointer to the sys-ex event to be sent.  MIDISendSysex will advance this pointer as bytes are sent.
             :data,                :pointer,
             # Initially, the number of bytes to be sent. MIDISendSysex will decrement this counter as bytes are sent.
             :bytes_to_send,       :uint32,
             # The client may set this to true at any time to abort transmission. The implementation sets this to true when all bytes have been sent.
             :complete,            :int,
             :reserved,            [:char, 3],
             # Called when all bytes have been sent, or after the client has set complete to true.
             :completion_proc,     :sysex_output_callback,
             # Passed as a refCon to completionProc.
             :completion_ref_con,  :pointer
    end

    attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :int

    attach_function :MIDIClientDispose, [:pointer], :int

    # MIDIEntityRef MIDIDeviceGetEntity (MIDIDeviceRef  device, ItemCount entityIndex0);
    attach_function :MIDIDeviceGetEntity, [TypeAliases::MIDIDeviceRef, TypeAliases::ItemCount], TypeAliases::MIDIEntityRef

    attach_function :MIDIGetNumberOfDestinations, [], TypeAliases::ItemCount

    attach_function :MIDIGetNumberOfDevices, [], TypeAliases::ItemCount

    attach_function :MIDIGetDestination, [:int], :pointer

    # MIDIEndpointRef MIDIEntityGetDestination( MIDIEntityRef entity, ItemCount destIndex0 );
    attach_function :MIDIEntityGetDestination, [:pointer, :int], TypeAliases::MIDIEndpointRef

    # ItemCount MIDIEntityGetNumberOfDestinations (MIDIEntityRef  entity);
    attach_function :MIDIEntityGetNumberOfDestinations, [TypeAliases::MIDIEntityRef], TypeAliases::ItemCount

    # ItemCount MIDIEntityGetNumberOfSources (MIDIEntityRef  entity);
    attach_function :MIDIEntityGetNumberOfSources, [:pointer], TypeAliases::ItemCount

    # MIDIEndpointRef MIDIEntityGetSource (MIDIEntityRef  entity, ItemCount sourceIndex0);
    attach_function :MIDIEntityGetSource, [TypeAliases::MIDIEntityRef, TypeAliases::ItemCount], TypeAliases::MIDIEndpointRef

    attach_function :MIDIGetDevice, [TypeAliases::ItemCount], TypeAliases::MIDIDeviceRef

    # OSStatus MIDIObjectGetStringProperty (MIDIObjectRef  obj, CFStringRef propertyID, CFStringRef *str);
    attach_function :MIDIObjectGetStringProperty, [TypeAliases::MIDIObjectRef, TypeAliases::CFStringRef, :pointer], TypeAliases::OSStatus

    attach_function :MIDIOutputPortCreate, [:pointer, :pointer, :pointer], :int

    attach_function :MIDIPacketListInit, [:pointer], :pointer

    attach_function :MIDISend, [:pointer, :pointer, :pointer], :int

    attach_function :MIDISendSysex, [:pointer], :int

    if SnowLeopard
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :pointer], :pointer
    else
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :int, :pointer], :pointer
    end

    module CF

      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'

      # CFString* CFStringCreateWithCString( ?, CString, encoding)
      attach_function :CFStringCreateWithCString, [:pointer, :string, :int], :pointer
      # CString* CFStringGetCStringPtr(CFString*, encoding)
      attach_function :CFStringGetCStringPtr, [:pointer, :int], :pointer

    end

  end

end
