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

    # readProc(const MIDIPacketList *newPackets, void *refCon, void *connRefCon)
    #@blocking = true
    #callback :readProc, [:pointer, :pointer, :pointer], :pointer

    #@blocking = true
    #callback :sysex_output_callback, [:pointer], :pointer

    typedef :pointer, :CFStringRef
    typedef :int32, :ItemCount
    typedef :pointer, :MIDIClientRef
    typedef :pointer, :MIDIDeviceRef
    typedef :pointer, :MIDIEndpointRef
    typedef :pointer, :MIDIEntityRef
    typedef :pointer, :MIDIObjectRef
    typedef :pointer, :MIDIPortRef
    typedef :pointer, :MIDIReadProc
    typedef :int32, :OSStatus

    class MIDISysexSendRequest < FFI::Struct

      layout :destination,         :MIDIEndpointRef,
             :data,                :pointer,
             :bytes_to_send,       :uint32,
             :complete,            :int,
             :reserved,            [:char, 3],
             :completion_proc,     :pointer,
             :completion_ref_con,  :pointer
    end

    attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :int

    attach_function :MIDIClientDispose, [:pointer], :int

    # MIDIEntityRef MIDIDeviceGetEntity (MIDIDeviceRef  device, ItemCount entityIndex0);
    attach_function :MIDIDeviceGetEntity, [:MIDIDeviceRef, :ItemCount], :MIDIEntityRef

    attach_function :MIDIGetNumberOfDestinations, [], :ItemCount

    attach_function :MIDIGetNumberOfDevices, [], :ItemCount

    attach_function :MIDIGetDestination, [:int], :pointer

    # MIDIEndpointRef MIDIEntityGetDestination( MIDIEntityRef entity, ItemCount destIndex0 );
    attach_function :MIDIEntityGetDestination, [:MIDIEntityRef, :int], :MIDIEndpointRef

    # ItemCount MIDIEntityGetNumberOfDestinations (MIDIEntityRef  entity);
    attach_function :MIDIEntityGetNumberOfDestinations, [:MIDIEntityRef], :ItemCount

    # ItemCount MIDIEntityGetNumberOfSources (MIDIEntityRef  entity);
    attach_function :MIDIEntityGetNumberOfSources, [:MIDIEntityRef], :ItemCount

    # MIDIEndpointRef MIDIEntityGetSource (MIDIEntityRef  entity, ItemCount sourceIndex0);
    attach_function :MIDIEntityGetSource, [:MIDIEntityRef, :ItemCount], :MIDIEndpointRef

    attach_function :MIDIGetDevice, [:ItemCount], :MIDIDeviceRef
    
    # extern OSStatus MIDIInputPortCreate( MIDIClientRef client, CFStringRef portName, MIDIReadProc readProc, void * refCon, MIDIPortRef * outPort );
    attach_function :MIDIInputPortCreate, [:MIDIClientRef, :CFStringRef, :MIDIReadProc, :pointer, :MIDIPortRef], :OSStatus

    # OSStatus MIDIObjectGetStringProperty (MIDIObjectRef  obj, CFStringRef propertyID, CFStringRef *str);
    attach_function :MIDIObjectGetStringProperty, [:MIDIObjectRef, :CFStringRef, :pointer], :OSStatus
                                                                                                                    \
    # extern OSStatus MIDIOutputPortCreate( MIDIClientRef client, CFStringRef portName, MIDIPortRef * outPort );
    attach_function :MIDIOutputPortCreate, [:MIDIClientRef, :CFStringRef, :pointer], :int

    attach_function :MIDIPacketListInit, [:pointer], :pointer

    #extern OSStatus MIDIPortConnectSource( MIDIPortRef port, MIDIEndpointRef source, void * connRefCon )
    attach_function :MIDIPortConnectSource, [:MIDIPortRef, :MIDIEndpointRef, :pointer], :OSStatus

    #extern OSStatus MIDIPortDisconnectSource( MIDIPortRef port, MIDIEndpointRef source );
    attach_function :MIDIPortDisconnectSource, [:MIDIPortRef, :MIDIEndpointRef], :OSStatus

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
