#!/usr/bin/env ruby

module CoreMIDI

  #
  # Input entity class
  #
  class Input

    include Entity
    
    attr_reader :buffer

    #
    # returns an array of MIDI event hashes as such:
    #   [
    #     { :data => [144, 60, 100], :timestamp => 1024 },
    #     { :data => [128, 60, 100], :timestamp => 1100 },
    #     { :data => [144, 40, 120], :timestamp => 1200 }
    #   ]
    #
    # the data is an array of Numeric bytes
    # the timestamp is the number of millis since this input was enabled
    #
    def gets
      until queued_messages?
      end
      msgs = queued_messages
      @pointer = @buffer.length
      msgs
    end
    alias_method :read, :gets

    # same as gets but returns message data as string of hex digits as such:
    #   [
    #     { :data => "904060", :timestamp => 904 },
    #     { :data => "804060", :timestamp => 1150 },
    #     { :data => "90447F", :timestamp => 1300 }
    #   ]
    #
    #
    def gets_s
      msgs = gets
      msgs.each { |msg| msg[:data] = numeric_bytes_to_hex_string(msg[:data]) }
      msgs
    end
    alias_method :gets_bytestr, :gets_s

    # enable this the input for use; can be passed a block
    def enable(options = {}, &block)
      enable_entity
      initialize_port
      connect_endpoint

      @port = FFI::MemoryPointer.new(:pointer)

      error = Map.MIDIPortConnectSource(@handle, @endpoint, nil )
      raise "Map.MIDIPortConnectSource returned error code #{error}" unless error.zero?
      
      initialize_buffer
      @sysex_buffer = []
      @start_time = Time.now.to_f
      @enabled = true

      unless block.nil?
        begin
          block.call(self)
        ensure
          close
        end
      else
        self
      end
    end
    alias_method :open, :enable
    alias_method :start, :enable

    # close this input
    def close
      error = Map.MIDIPortDisconnectSource( @handle, @endpoint )
      raise "MIDIPortDisconnectSource returned error code #{error}" unless error.zero?
      error = Map.MIDIPortDispose(@handle)
      raise "MIDIPortDisposePort returned error code #{error}" unless error.zero?
      @enabled = false
    end

    def self.first
      Entity.first(:input)
    end

    def self.last
      Entity.last(:input)
    end

    def self.all
      Entity.all_by_type[:input]
    end

    private

    def queued_messages
      @buffer.slice(@pointer, @buffer.length - @pointer)
    end

    def queued_messages?
      @pointer < @buffer.length
    end

    def get_event_callback
      Proc.new do | new_packets, refCon_ptr, connRefCon_ptr |
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
          @buffer << get_message_formatted(bytes) if @sysex_buffer.empty?             
        end
      end
    end

    # give a message its timestamp and package it in a Hash
    def get_message_formatted(raw)
      time = ((Time.now.to_f - @start_time) * 1000)
      { :data => raw, :timestamp => time }
    end

    def initialize_port
      port_name = Map::CF.CFStringCreateWithCString(nil, "Port #{@id}: #{@name}", 0)
      handle_ptr = FFI::MemoryPointer.new(:pointer)
      @callback = get_event_callback
      error = Map.MIDIInputPortCreate(@client, port_name, @callback, nil, handle_ptr)
      @handle = handle_ptr.read_pointer
      raise "MIDIInputPortCreate returned error code #{error}" unless error.zero?
    end

    def connect_endpoint
      @endpoint = Map.MIDIEntityGetSource(@entity_pointer, 0)
    end
    
    def initialize_buffer
      @pointer = 0
      @buffer = []
      def @buffer.clear
        super
        @pointer = 0
      end     
    end
    
    def numeric_bytes_to_hex_string(bytes)
      bytes.map { |b| s = b.to_s(16).upcase; b < 16 ? s = "0" + s : s; s }.join
    end 

  end

end
