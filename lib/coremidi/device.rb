#!/usr/bin/env ruby

module CoreMIDI

  class Device

    attr_reader :entities,
                # unique Numeric id
                :id,
                # device name from coremidi
                :name

    def initialize(id, device_pointer)
      @id = id
      prop = Map::CF.CFStringCreateWithCString( nil, "name", 0 )
      name = Map::CF.CFStringCreateWithCString( nil, id.to_s, 0 )
      Map::MIDIObjectGetStringProperty(device_pointer, prop, name)

      @name = Map::CF.CFStringGetCStringPtr(name.read_pointer, 0).read_string
    end

    def self.all
      devices = []
      i = 0
      while !(device_pointer = Map.MIDIGetDevice(i)).null?
        devices << new(i, device_pointer)
        i+=1
      end
      devices
    end

  end

end