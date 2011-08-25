#!/usr/bin/env ruby

module CoreMIDI

  class Device

    attr_reader :endpoints,
                # unique Numeric id
                :id,
                # device name from coremidi
                :name

    def initialize(id, entity_count, device_pointer, include_if_offline)
      @id = id
      @device_pointer = device_pointer
      prop = Map::CF.CFStringCreateWithCString( nil, "name", 0 )
      name = Map::CF.CFStringCreateWithCString( nil, id.to_s, 0 )
      Map::MIDIObjectGetStringProperty(@device_pointer, prop, name)

      @name = Map::CF.CFStringGetCStringPtr(name.read_pointer, 0).read_string
      populate_entities(entity_count, include_if_offline)
    end

    def self.all(options = {})
      include_offline = options[:include_offline] || false
      devices = []
      i = 0
      endpoint_counter = 0
      while !(device_pointer = Map.MIDIGetDevice(i)).null?
        device = new(i, endpoint_counter, device_pointer, include_offline)
        devices << device
        endpoint_counter += device.endpoints.values.flatten.length
        i+=1
      end
      devices
    end

    private

    def populate_endpoints(type, entity_pointer, starting_id, include_if_offline)
      endpoint_type, device_class = *case type
        when :input then [:source, Input]
        when :output then [:destination, Output]
      end  
      id = starting_id
      num_endpoints = get_endpoints(endpoint_type, entity_pointer)
      (0..num_endpoints).each do |i|
        dev = device_class.new((i + starting_id), i, entity_pointer, include_if_offline)
        @endpoints[type] << dev if dev.online? || include_if_offline
      end  
      @endpoints[type].size   
    end
    
    def get_endpoints(type, entity_pointer)
      case type
        when :source then Map.MIDIEntityGetNumberOfSources(entity_pointer)
        when :destination then Map.MIDIEntityGetNumberOfDestinations(entity_pointer)
      end
    end

    def populate_entities(starting_id, include_if_offline)
      @endpoints = { :input => [], :output => [] }
      id = starting_id
      i = 0
      while !(entity_pointer = Map.MIDIDeviceGetEntity(@device_pointer, i)).null?
        [:input, :output].each do |type|
          id += populate_endpoints(type, entity_pointer, id, include_if_offline)
        end
        i += 1
      end
    end

  end

end