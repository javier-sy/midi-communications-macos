module CoreMIDI

  # Output/Destination endpoint class
  class Destination

    include Endpoint

    attr_reader :entity

    # Close this output
    # @return [Boolean]
    def close
      if @enabled
        @enabled = false
        true
      else
        false
      end
    end

    # Send a MIDI message comprised of a String of hex digits
    # @param [String] data A string of hex digits eg "904040"
    # @return [Boolean]
    def puts_s(data)
      data = data.dup
	    bytes = []
      until (str = data.slice!(0,2)).eql?("")
      	bytes << str.hex
      end
      puts_bytes(*bytes)
      true
    end
    alias_method :puts_bytestr, :puts_s
    alias_method :puts_hex, :puts_s

    # Send a MIDI message comprised of numeric bytes
    # @param [*Fixnum] data Numeric bytes eg 0x90, 0x40, 0x40
    # @return [Boolean]
    def puts_bytes(*data)
      type = sysex?(data) ? :sysex : :small
      bytes = pack_data(data)
      send("puts_#{type.to_s}", bytes, data.size)
      true
    end

    # Send a MIDI message of indeterminate type
    # @param [*Array<Fixnum>, *Array<String>, *Fixnum, *String] args
    # @return [Boolean]
    def puts(*args)
  	  case args.first
      when Array then puts_bytes(*args.first)
    	when Fixnum then puts_bytes(*args)
    	when String then puts_bytestr(*args)
      end
    end
    alias_method :write, :puts

    # Enable this device
    # @return [Destination]
    def enable(options = {}, &block)
      if !@enabled
        @enabled = true
        if block_given?
      	  begin
      		  yield(self)
      	  ensure
      		  close
      	  end
        end
      end
      self
    end
    alias_method :open, :enable
    alias_method :start, :enable

    # Shortcut to the first output endpoint available
    # @return [Destination]
    def self.first
      Endpoint.first(:destination)
    end
    
    # Shortcut to the last output endpoint available
    # @return [Destination]
    def self.last
      Endpoint.last(:destination)
    end

    # All output endpoints
    # @return [Array<Destination>]
    def self.all
      Endpoint.all_by_type[:destination]
    end
    
    protected

    # Base initialization for this endpoint -- done whether or not the endpoint is enabled to
    # check whether it is truly available for use
    # @return [Boolean]
    def connect
      client_error = enable_client
      port_error = initialize_port
      @resource = API.MIDIEntityGetDestination( @entity.resource, @resource_id )
      !@resource.address.zero? && client_error.zero? && port_error.zero?
    end
    alias_method :connect?, :connect

    private

    # Output a short MIDI message
    def puts_small(bytes, size)
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = API.MIDIPacketListInit(packet_list)
      packet_ptr = if API::SnowLeopard
        API.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, size, bytes)
      else
        # Pass in two 32-bit 0s for the 64 bit time
        API.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, 0, size, bytes)
      end
      API.MIDISend( @handle, @resource, packet_list )
      true
    end

    # Output a System Exclusive MIDI message
    def puts_sysex(bytes, size)
      request = API::MIDISysexSendRequest.new
      request[:destination] = @resource
      request[:data] = bytes
      request[:bytes_to_send] = size
      request[:complete] = 0
      request[:completion_proc] = SysexCompletionCallback
      request[:completion_ref_con] = request
      API.MIDISendSysex(request)
      true
    end

    SysexCompletionCallback =
      FFI::Function.new(:void, [:pointer]) do |sysex_request_ptr|
        # this isn't working for some reason. as of now, it's not needed though
      end
      
    # Initialize a coremidi port for this endpoint
    def initialize_port
      port_name = API::CF.CFStringCreateWithCString(nil, "Port #{@resource_id}: #{name}", 0)
      outport_ptr = FFI::MemoryPointer.new(:pointer)
      error = API.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      @handle = outport_ptr.read_pointer
      error
    end

    # Pack the given data into a coremidi MIDI packet
    def pack_data(data)
      format = "C" * data.size
      packed_data = data.pack(format)
      char_size = FFI.type_size(:char) * data.size
      bytes = FFI::MemoryPointer.new(char_size)
      bytes.write_string(packed_data)
      bytes
    end

    # Is the given data a MIDI sysex message?
    def sysex?(data)
      data.first.eql?(0xF0) && data.last.eql?(0xF7)
    end

  end

end
