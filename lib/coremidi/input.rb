#!/usr/bin/env ruby

module CoreMIDI

  #
  # Input entity class
  #
  class Input

    include Entity

    #
    # returns an array of MIDI event hashes as such:
    # [
    #   { :data => [144, 60, 100], :timestamp => 1024 },
    #   { :data => [128, 60, 100], :timestamp => 1100 },
    #   { :data => [144, 40, 120], :timestamp => 1200 }
    # ]
    #
    # the data is an array of Numeric bytes
    # the timestamp is the number of millis since this input was enabled
    #
    def gets
      @listener.join
      msgs = @buffer.dup
      @buffer.clear
      spawn_listener
      msgs
    end
    alias_method :read, :gets

    # same as gets but returns message data as string of hex digits as such:
    # [
    #   { :data => "904060", :timestamp => 904 },
    #   { :data => "804060", :timestamp => 1150 },
    #   { :data => "90447F", :timestamp => 1300 }
    # ]
    #
    #
    def gets_s
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

      @buffer = []
      @start_time = Time.now.to_f
      @enabled = true
      spawn_listener

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
      Map.MIDIPortDisconnectSource( @client, @endpoint )
      Thread.kill(@listener)
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

    EventCallback = FFI::Function.new(:pointer, [:pointer, :pointer, :pointer]) do | newPackets_ptr, refCon_ptr, connRefCon_ptr |
      packet_list = Map::MIDIPacketList.new(newPackets_ptr)
      p packet_list

    end

    # launch a background thread that collects messages
    def spawn_listener
      @listener = Thread.fork do
        while @buffer.empty? do
          sleep(0.1)
        end
      end
    end

    def initialize_port
      port_name = Map::CF.CFStringCreateWithCString(nil, "Port #{@id}: #{@name}", 0)
      handle_ptr = FFI::MemoryPointer.new(:pointer)
      error = Map.MIDIInputPortCreate(@client, port_name, EventCallback, nil, handle_ptr)
      @handle = handle_ptr.read_pointer
      raise "MIDIInputPortCreate returned error code #{error}" unless error.zero?
    end

    def connect_endpoint
      @endpoint = Map.MIDIEntityGetSource(@entity_pointer, 0)
    end

  end

end