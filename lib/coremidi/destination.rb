#!/usr/bin/env ruby

module CoreMIDI

  #
  # Output/Destination endpoint class
  #
  class Destination

    include Endpoint

    attr_reader :entity

    # close this output
    def close
      #error = Map.MIDIClientDispose(@handle)
      #raise "MIDIClientDispose returned error code #{error}" unless error.zero?
      #error = Map.MIDIPortDispose(@handle)
      #raise "MIDIPortDispose returned error code #{error}" unless error.zero?
      #error = Map.MIDIEndpointDispose(@resource)
      #raise "MIDIEndpointDispose returned error code #{error}" unless error.zero?
      @enabled = false

    end

    # sends a MIDI message comprised of a String of hex digits
    def puts_s(data)
      data = data.dup
	    output = []
      until (str = data.slice!(0,2)).eql?("")
      	output << str.hex
      end
      puts_bytes(*output)
    end
    alias_method :puts_bytestr, :puts_s
    alias_method :puts_hex, :puts_s

    # sends a MIDI messages comprised of Numeric bytes
    def puts_bytes(*data)

      format = "C" * data.size
      bytes = (FFI::MemoryPointer.new FFI.type_size(:char) * data.size)
      bytes.write_string(data.pack(format))

      if data.first.eql?(0xF0) && data.last.eql?(0xF7)
        puts_sysex(bytes, data.size)
      else
        puts_small(bytes, data.size)
      end
    end

    # send a MIDI message of an indeterminant type
    def puts(*a)
  	  case a.first
        when Array then puts_bytes(*a.first)
    	when Numeric then puts_bytes(*a)
    	when String then puts_bytestr(*a)
      end
    end
    alias_method :write, :puts

    # enable this device
    def enable(options = {}, &block)
      @enabled = true
      if block_given?
      	begin
      		yield(self)
      	ensure
      		close
      	end
      else
        self
      end
    end
    alias_method :open, :enable
    alias_method :start, :enable

    # shortcut to the first output endpoint available
    def self.first
      Endpoint.first(:destination)
    end
    
    # shortcut to the last output endpoint available
    def self.last
      Endpoint.last(:destination)
    end

    # all output endpoints
    def self.all
      Endpoint.all_by_type[:destination]
    end
    
    protected

    # base initialization for this endpoint -- done whether or not the endpoint is enabled to
    # check whether it is truly available for use
    def connect
      client_error = enable_client
      port_error = initialize_port

      @resource = Map.MIDIEntityGetDestination( @entity.resource, @resource_id )
      !@resource.address.zero? && client_error.zero? && port_error.zero?
    end
    alias_method :connect?, :connect

    private

    # output a short MIDI message
    def puts_small(bytes, size)
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = Map.MIDIPacketListInit(packet_list)

      if Map::SnowLeopard
        packet_ptr = Map.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, size, bytes)
      else
        # Pass in two 32-bit 0s for the 64 bit time
        packet_ptr = Map.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, 0, size, bytes)
      end

      Map.MIDISend( @handle, @resource, packet_list )
    end

    # output a System Exclusive MIDI message
    def puts_sysex(bytes, size)

      request = Map::MIDISysexSendRequest.new
      request[:destination] = @resource
      request[:data] = bytes
      request[:bytes_to_send] = size
      request[:complete] = 0
      request[:completion_proc] = SysexCompletionCallback
      request[:completion_ref_con] = request

      Map.MIDISendSysex(request)
    end

    SysexCompletionCallback =
      FFI::Function.new(:void, [:pointer]) do |sysex_request_ptr|
        # this isn't working for some reason
        # as of now, we don't need it though
      end
      
    # initialize a coremidi port for this endpoint
    def initialize_port
      port_name = Map::CF.CFStringCreateWithCString(nil, "Port #{@resource_id}: #{name}", 0)
      outport_ptr = FFI::MemoryPointer.new(:pointer)
      error = Map.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      @handle = outport_ptr.read_pointer
      error
    end

  end

end
