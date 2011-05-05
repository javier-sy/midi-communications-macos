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

    def connect_endpoint
      port_name = Map::CF.CFStringCreateWithCString(nil, "Port #{@id}: #{@name}", 0)
      endpoint_ptr = FFI::MemoryPointer.new(:pointer)
      @callback = get_event_callback
      Map.MIDIInputPortCreate(@client, port_name, @callback, nil, endpoint_ptr)
      @endpoint = endpoint_ptr.read_pointer
    end

    # enable this the input for use; can be passed a block
    def enable(options = {}, &block)
      enable_entity
      connect_endpoint

      @source = Map.MIDIPortConnectSource( @client, @endpoint, nil )

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

    def get_event_callback
      Proc.new do | newPackets_ptr, refCon_ptr, connRefCon_ptr |
        p 'hi'
      end
    end

    # launch a background thread that collects messages
    def spawn_listener
      @listener = Thread.fork do
        while @buffer.empty? do
          sleep(0.1)
        end
      end
    end

    private

  end

end