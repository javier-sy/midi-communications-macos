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
    
    # returns all devices which are cached in an instance variable @devices on the Device class
    #
    # options:
    # 
    # * <b>cache</b>: if false, the device list will never be cached. this would be useful if one needs to alter the device list (e.g. plug in a USB MIDI interface) while their program is running.
    # * <b>include_offline</b>: if true, devices marked offline by coremidi will be included in the list
    #
    def self.all(options = {})
      use_cache = options[:cache] || true
      include_offline = options[:include_offline] || false
      if @devices.nil? || @devices.empty? || !use_cache
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
    
    # Refresh the Device cash.  You'll need to do this if, for instance, you plug in
    # a USB MIDI device while the program is running 
    def self.refresh
      @devices.clear
    end

    private
    
    # assign all of this Device's endpoints an id
    def populate_endpoint_ids(starting_id)
      id = nil
      endpoints.values.flatten.each_with_index do |e, i| 
        id = (i + starting_id)
        e.id = id
      end
      id
    end
    
    # gives all of the endpoints for all devices an id
    def self.populate_endpoint_ids
      i = 0
      all.each { |device| i += device.populate_endpoint_ids(i) }
    end
 
    # populate endpoints for this device
    def populate_endpoints(type, entity_pointer, options = {})
      include_if_offline = options[:include_offline] || false
      endpoint_type, endpoint_class = *case type
        when :input then [:source, Input]
        when :output then [:destination, Output]
      end  
      num_endpoints = number_of_endpoints(endpoint_type, entity_pointer)
      (0..num_endpoints).each do |i|
        ep = endpoint_class.new(i, entity_pointer)
        @endpoints[type] << ep if ep.online? || include_if_offline
      end  
      @endpoints[type].size   
    end
    
    # gets the number of endpoints for this device
    def number_of_endpoints(type, entity_pointer)
      case type
        when :source then Map.MIDIEntityGetNumberOfSources(entity_pointer)
        when :destination then Map.MIDIEntityGetNumberOfDestinations(entity_pointer)
      end
    end

    # populates the entities for this device. these are in turn used to gather the endpoints
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
