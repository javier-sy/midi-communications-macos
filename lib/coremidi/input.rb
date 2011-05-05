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
    def gets_bytestr
    end

    # enable this the input for use; can be passed a block
    def enable(options = {}, &block)

      @enabled = true
      @start_time = Time.now.to_f
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
      Thread.kill(@listener)
      @enabled = false
    end

    def self.first
      Device.first(:input)
    end

    def self.last
      Device.last(:input)
    end

    def self.all
      Device.all_by_type[:input]
    end

    private

    # launch a background thread that collects messages
    def spawn_listener
      @listener = Thread.fork do
      end
    end

    private

  end

end