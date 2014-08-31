module CoreMIDI

  # Input/Source endpoint class
  class Source

    include Endpoint
    
    attr_reader :buffer

    #
    # An array of MIDI event hashes as such:
    #   [
    #     { :data => [144, 60, 100], :timestamp => 1024 },
    #     { :data => [128, 60, 100], :timestamp => 1100 },
    #     { :data => [144, 40, 120], :timestamp => 1200 }
    #   ]
    #
    # The data is an array of Numeric bytes
    # The timestamp is the number of millis since this input was enabled
    #
    # @return [Array<Hash>]
    def gets
      until queued_messages?
      end
      msgs = queued_messages
      @pointer = @buffer.length
      msgs
    end
    alias_method :read, :gets

    # Same as Source#gets except that it returns message data as string of hex 
    # digits as such:
    #   [
    #     { :data => "904060", :timestamp => 904 },
    #     { :data => "804060", :timestamp => 1150 },
    #     { :data => "90447F", :timestamp => 1300 }
    #   ]
    #
    # @return [Array<Hash>]
    def gets_s
      msgs = gets
      msgs.each { |msg| msg[:data] = numeric_bytes_to_hex_string(msg[:data]) }
      msgs
    end
    alias_method :gets_bytestr, :gets_s

    # Enable this the input for use; can be passed a block
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

    # Close this input
    def close
      #error = Map.MIDIPortDisconnectSource( @handle, @resource )
      #raise "MIDIPortDisconnectSource returned error code #{error}" unless error.zero?
      #error = Map.MIDIClientDispose(@handle)
      #raise "MIDIClientDispose returned error code #{error}" unless error.zero?
      #error = Map.MIDIPortDispose(@handle)
      #raise "MIDIPortDispose returned error code #{error}" unless error.zero?
      #error = Map.MIDIEndpointDispose(@resource)
      #raise "MIDIEndpointDispose returned error code #{error}" unless error.zero?
      @enabled = false
      true
    end

    # Shortcut to the first available input endpoint
    def self.first
      Endpoint.first(:source)
    end

    # Shortcut to the last available input endpoint
    def self.last
      Endpoint.last(:source)
    end

    # All input endpoints
    def self.all
      Endpoint.all_by_type[:source]
    end
    
    protected
    
    # Base initialization for this endpoint -- done whether or not the endpoint is enabled to check whether 
    # it is truly available for use
    def connect   
      enable_client
      initialize_port
      @resource = Map.MIDIEntityGetSource(@entity.resource, @resource_id)
      error = Map.MIDIPortConnectSource(@handle, @resource, nil )
      initialize_buffer
      @sysex_buffer = []
      @start_time = Time.now.to_f

      error.zero?
    end
    alias_method :connect?, :connect

    private

    # New MIDI messages from the queue
    def queued_messages
      @buffer.slice(@pointer, @buffer.length - @pointer)
    end

    # Are there new MIDI messages in the queue?
    def queued_messages?
      @pointer < @buffer.length
    end

    # The callback fired by coremidi when new MIDI messages are in the buffer
    def get_event_callback
      Proc.new do | new_packets, refCon_ptr, connRefCon_ptr |
        time = Time.now.to_f
        packet = new_packets[:packet][0]
        len = packet[:length]
        #p "packets received: #{new_packets[:numPackets]}"
        #p "first packet length: #{len} data: #{packet[:data].to_a.to_s}"
        if len > 0
          bytes = packet[:data].to_a[0, len]
          if bytes.first.eql?(0xF0) || !@sysex_buffer.empty?
            @sysex_buffer += bytes
            if bytes.last.eql?(0xF7)
              bytes = @sysex_buffer.dup
              @sysex_buffer.clear
            end
          end
          @buffer << get_message_formatted(bytes, time) if @sysex_buffer.empty?             
        end
      end
    end

    # Timestamp for a received MIDI message
    def timestamp(now)
      (now - @start_time) * 1000
    end

    # Give a message its timestamp and package it in a Hash
    def get_message_formatted(raw, time)
      { 
        :data => raw, 
        :timestamp => timestamp(time) 
      }
    end

    # Initialize a coremidi port for this endpoint
    def initialize_port
      port_name = Map::CF.CFStringCreateWithCString(nil, "Port #{@resource_id}: #{name}", 0)
      handle_ptr = FFI::MemoryPointer.new(:pointer)
      @callback = get_event_callback
      error = Map.MIDIInputPortCreate(@client, port_name, @callback, nil, handle_ptr)
      @handle = handle_ptr.read_pointer
      raise "MIDIInputPortCreate returned error code #{error}" unless error.zero?
      true
    end
    
    # Initialize the MIDI message buffer
    def initialize_buffer
      @pointer = 0
      @buffer = []
      def @buffer.clear
        super
        @pointer = 0
      end
      true
    end
    
    # Convert an array of numeric byes to a hex string (e.g. [0x90, 0x40, 0x40] becomes "904040")
    def numeric_bytes_to_hex_string(bytes)
      string_bytes = bytes.map do |byte| 
        str = byte.to_s(16).upcase
        str = "0" + str if byte < 16
        str
      end
      string_bytes.join
    end 

  end

end
