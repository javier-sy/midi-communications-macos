#!/usr/bin/env ruby

module CoreMIDI

  #
  # coremidi binding
  #
  #
  module Map

    extend FFI::Library
    ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

    SnowLeopard = `uname -r` =~ /10\.\d\.\d/

    typedef :pointer, :CFStringRef
    typedef :int32, :ItemCount
    typedef :pointer, :MIDIClientRef
    typedef :pointer, :MIDIDeviceRef
    typedef :pointer, :MIDIEndpointRef
    typedef :pointer, :MIDIEntityRef
    typedef :pointer, :MIDIObjectRef
    typedef :pointer, :MIDIPortRef
    #typedef :pointer, :MIDIReadProc
    typedef :uint32, :MIDITimeStamp
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

    class MIDIPacket < FFI::Struct

      layout :timestamp, :MIDITimeStamp,
             :nothing, :uint32, # no idea...
             :length, :uint16,
             :data, [:uint8, 256]

    end

    class MIDIPacketList < FFI::Struct
      layout :numPackets, :uint32,
             :packet, [MIDIPacket.by_value, 1]

    end

    callback :MIDIReadProc, [MIDIPacketList.by_ref, :pointer, :pointer], :pointer

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

    # extern OSStatus MIDIObjectGetIntegerProperty( MIDIObjectRef obj, CFStringRef propertyID, SInt32 * outValue );
    attach_function :MIDIObjectGetIntegerProperty, [:MIDIObjectRef, :CFStringRef, :pointer], :OSStatus
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

    #extern OSStatus MIDIPortDispose(MIDIPortRef port );
    attach_function :MIDIPortDispose, [:MIDIPortRef], :OSStatus

    #extern OSStatus MIDISend(MIDIPortRef port,MIDIEndpointRef dest,const MIDIPacketList *pktlist);
    attach_function :MIDISend, [:MIDIPortRef, :MIDIEndpointRef, :pointer], :int

    attach_function :MIDISendSysex, [:pointer], :int

    if SnowLeopard
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :pointer], :pointer
    else
      # extern MIDIPacket * MIDIPacketListAdd( MIDIPacketList * pktlist, ByteCount listSize, MIDIPacket * curPacket, MIDITimeStamp time, ByteCount nData, const Byte * data)
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

    module HostTime
      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreAudio.framework/Versions/Current/CoreAudio'

      attach_function :AudioConvertHostTimeToNanos, [:uint64], :uint64
    end

  end

end
