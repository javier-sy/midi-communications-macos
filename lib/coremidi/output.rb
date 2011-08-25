#!/usr/bin/env ruby

module CoreMIDI

  #
  # Output endpoint class
  #
  class Output

    include Endpoint

    # close this output
    def close
      Map.MIDIClientDispose( @client )
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

    # enable this device; also takes a block
    def enable(options = {}, &block)
      @enabled = true
      unless block.nil?
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
    
    def connect
      enable_client
      get_endpoint

      @destination = Map.MIDIEntityGetDestination( @entity_pointer, @endpoint_id )
    end
    
    def connect?
      connect
      !@destination.nil?
    end

    def self.first
      Endpoint.first(:output)
    end

    def self.last
      Endpoint.last(:output)
    end

    def self.all
      Endpoint.all_by_type[:output]
    end

    private

    def puts_small(bytes, size)
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = Map.MIDIPacketListInit(packet_list)

      if Map::SnowLeopard
        packet_ptr = Map.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, size, bytes)
      else
        # Pass in two 32-bit 0s for the 64 bit time
        packet_ptr = Map.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, 0, size, bytes)
      end

      Map.MIDISend( @endpoint, @destination, packet_list )
    end

    def puts_sysex(bytes, size)

      #@callback =

      request = Map::MIDISysexSendRequest.new
      request[:destination] = @destination
      request[:data] = bytes
      request[:bytes_to_send] = size
      request[:complete] = 0
      request[:completion_proc] = SysexCompletionCallback
      request[:completion_ref_con] = request

      Map.MIDISendSysex(request)
    end

    SysexCompletionCallback =
      FFI::Function.new(:void, [:pointer]) do |sysex_request_ptr|
        p 'hi'
        # this isn't working for some reason
        # as of now, we don't need it though
      end

    private

    def get_endpoint
      port_name = Map::CF.CFStringCreateWithCString(nil, "Port #{@id}: #{@name}", 0)
      outport_ptr = FFI::MemoryPointer.new(:pointer)
      Map.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      @endpoint = outport_ptr.read_pointer
    end

  end

end