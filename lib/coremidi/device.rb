#!/usr/bin/env ruby

module CoreMIDI

  class Device

    attr_reader :endpoints,
                # unique Numeric id
                :id,
                # device name from coremidi
                :name

    def initialize(id, device_pointer, options = {})
      include_if_offline = options[:include_offline] || false
      @id = id
      @device_pointer = device_pointer
      @endpoints = { :input => [], :output => [] }
      
      prop = Map::CF.CFStringCreateWithCString( nil, "name", 0 )
      name = Map::CF.CFStringCreateWithCString( nil, id.to_s, 0 )
      Map::MIDIObjectGetStringProperty(@device_pointer, prop, name)

      @name = Map::CF.CFStringGetCStringPtr(name.read_pointer, 0).read_string
      populate_entities(:include_offline => include_if_offline)
    end

    def self.all(options = {})
      include_offline = options[:include_offline] || false
      if @devices.nil? || @devices.empty?
        @devices = []
        i = 0
        while !(device_pointer = Map.MIDIGetDevice(i)).null?
          device = new(i, device_pointer, :include_offline => include_offline)
          @devices << device
          i+=1
        end
        populate_endpoint_ids
      end
      @devices
    end
    
    def self.refresh
      @devices.clear
    end

    private
    
    def self.populate_endpoint_ids
      i = 0
      all.each_with_index do |device|         
        device.endpoints.values.flatten.each { |e| e.id = (i += 1) }
      end
    end

    def populate_endpoints(type, entity_pointer, options = {})
      include_if_offline = options[:include_offline] || false
      endpoint_type, endpoint_class = *case type
        when :input then [:source, Input]
        when :output then [:destination, Output]
      end  
      num_endpoints = get_endpoints(endpoint_type, entity_pointer)
      (0..num_endpoints).each do |i|
        ep = endpoint_class.new(i, entity_pointer)
        @endpoints[type] << ep if ep.online? || include_if_offline
      end  
      @endpoints[type].size   
    end
    
    def get_endpoints(type, entity_pointer)
      case type
        when :source then Map.MIDIEntityGetNumberOfSources(entity_pointer)
        when :destination then Map.MIDIEntityGetNumberOfDestinations(entity_pointer)
      end
    end

    def populate_entities(options = {})
      include_if_offline = options[:include_offline] || false
      i = 0
      while !(entity_pointer = Map.MIDIDeviceGetEntity(@device_pointer, i)).null?
        [:input, :output].each do |type|
          populate_endpoints(type, entity_pointer, :include_offline => include_if_offline)
        end
        i += 1
      end
    end

  end

end
