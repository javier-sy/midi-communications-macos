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
      @device_pointer = device_pointer
      prop = Map::CF.CFStringCreateWithCString( nil, "name", 0 )
      name = Map::CF.CFStringCreateWithCString( nil, id.to_s, 0 )
      Map::MIDIObjectGetStringProperty(@device_pointer, prop, name)

      @name = Map::CF.CFStringGetCStringPtr(name.read_pointer, 0).read_string
      populate_entities
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

    private

    def populate_entities
      entities = { :input => [], :output => [] }
      id = 0
      i = 0
      while !(entity_pointer = Map.MIDIDeviceGetEntity(@device_pointer, i)).null?
        dests = Map.MIDIEntityGetNumberOfDestinations(entity_pointer)
        sources = Map.MIDIEntityGetNumberOfSources(entity_pointer)
        if sources > 0
          entities[:input] << Input.new(id, entity_pointer)
          id += 1
        end
        if dests > 0
          entities[:output] << Output.new(id, entity_pointer)
          id += 1
        end
        i+=1
      end
      @entities = entities
    end

  end

end