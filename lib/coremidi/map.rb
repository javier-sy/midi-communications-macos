#!/usr/bin/env ruby

module CoreMIDI

  #
  # coremidi struct, enum and function bindings
  #
  #
  module Map

    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

    SnowLeopard = `uname -r` =~ /10\.\d\.\d/

    module TypeAliases
      CFStringRef = :pointer
      ItemCount = :int
      MIDIClientRef = :pointer
      MIDIDeviceRef = :pointer
      MIDIEndpointRef = :pointer
      MIDIEntityRef = :pointer
      MIDIObjectRef = :pointer
      MIDIPortRef = :pointer
      MIDIReadProc = :pointer
      OSStatus = :int
    end
    TA = TypeAliases

    callback :sysex_output_callback, [:pointer], :void

    class MIDISysexSendRequest < FFI::Struct

      layout :destination,         TA::MIDIEndpointRef,
             :data,                :pointer,
             :bytes_to_send,       :uint32,
             :complete,            :int,
             :reserved,            [:char, 3],
             :completion_proc,     :sysex_output_callback,
             :completion_ref_con,  :pointer
    end

    attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :int

    attach_function :MIDIClientDispose, [:pointer], :int

    # MIDIEntityRef MIDIDeviceGetEntity (MIDIDeviceRef  device, ItemCount entityIndex0);
    attach_function :MIDIDeviceGetEntity, [TA::MIDIDeviceRef, TA::ItemCount], TA::MIDIEntityRef

    attach_function :MIDIGetNumberOfDestinations, [], TA::ItemCount

    attach_function :MIDIGetNumberOfDevices, [], TA::ItemCount

    attach_function :MIDIGetDestination, [:int], :pointer

    # MIDIEndpointRef MIDIEntityGetDestination( MIDIEntityRef entity, ItemCount destIndex0 );
    attach_function :MIDIEntityGetDestination, [:pointer, :int], TA::MIDIEndpointRef

    # ItemCount MIDIEntityGetNumberOfDestinations (MIDIEntityRef  entity);
    attach_function :MIDIEntityGetNumberOfDestinations, [TA::MIDIEntityRef], TA::ItemCount

    # ItemCount MIDIEntityGetNumberOfSources (MIDIEntityRef  entity);
    attach_function :MIDIEntityGetNumberOfSources, [:pointer], TA::ItemCount

    # MIDIEndpointRef MIDIEntityGetSource (MIDIEntityRef  entity, ItemCount sourceIndex0);
    attach_function :MIDIEntityGetSource, [TA::MIDIEntityRef, TA::ItemCount], TA::MIDIEndpointRef

    attach_function :MIDIGetDevice, [TA::ItemCount], TA::MIDIDeviceRef
    
    # extern OSStatus MIDIInputPortCreate( MIDIClientRef client, CFStringRef portName, MIDIReadProc readProc, void * refCon, MIDIPortRef * outPort );
    attach_function :MIDIInputPortCreate, [TA::MIDIClientRef, TA::CFStringRef, TA::MIDIReadProc, :pointer, TA::MIDIPortRef], TA::OSStatus

    # OSStatus MIDIObjectGetStringProperty (MIDIObjectRef  obj, CFStringRef propertyID, CFStringRef *str);
    attach_function :MIDIObjectGetStringProperty, [TA::MIDIObjectRef, TA::CFStringRef, :pointer], TA::OSStatus

    # extern OSStatus MIDIOutputPortCreate( MIDIClientRef client, CFStringRef portName, MIDIPortRef * outPort );
    attach_function :MIDIOutputPortCreate, [TA::MIDIClientRef, TA::CFStringRef, :pointer], :int

    attach_function :MIDIPacketListInit, [:pointer], :pointer

    #extern OSStatus MIDIPortConnectSource( MIDIPortRef port, MIDIEndpointRef source, void * connRefCon )
    attach_function :MIDIPortConnectSource, [TA::MIDIPortRef, TA::MIDIEndpointRef, :pointer], TA::OSStatus

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
