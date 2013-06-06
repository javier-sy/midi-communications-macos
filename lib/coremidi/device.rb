#!/usr/bin/env ruby

module CoreMIDI

  class Device

    attr_reader :entities,
                # unique Numeric id
                :id,
                # device name from coremidi
                :name

    def initialize(id, device_pointer, options = {})
      include_if_offline = options[:include_offline] || false
      @id = id
      @resource = device_pointer
      @entities = []
      
      prop = Map::CF.CFStringCreateWithCString( nil, "name", 0 )

      begin
        name_ptr = FFI::MemoryPointer.new(:pointer)
        Map::MIDIObjectGetStringProperty(@resource, prop, name_ptr)
        name = name_ptr.read_pointer
        len = Map::CF.CFStringGetMaximumSizeForEncoding(Map::CF.CFStringGetLength(name), :kCFStringEncodingUTF8)
        bytes = FFI::MemoryPointer.new(len + 1)
        raise RuntimeError.new("CFStringGetCString") unless Map::CF.CFStringGetCString(name, bytes, len, :kCFStringEncodingUTF8)
        @name = bytes.read_string
      ensure
        Map::CF.CFRelease(name) unless name.nil? || name.null?
        Map::CF.CFRelease(prop) unless prop.null?
      end

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
    
    # returns all of the Endpoints for this device
    def endpoints
      endpoints = { :source => [], :destination => [] }
      endpoints.keys.each do |k|
        endpoints[k] += entities.map { |entity| entity.endpoints[k] }.flatten
      end
      endpoints
    end
    
    # assign all of this Device's endpoints an consecutive local id
    def populate_endpoint_ids(starting_id)
      i = 0
      entities.each { |entity| i += entity.populate_endpoint_ids(i + starting_id) }
      i
    end

    private
    
    # gives all of the endpoints for all devices a consecutive local id
    def self.populate_endpoint_ids
      i = 0
      all.each { |device| i += device.populate_endpoint_ids(i) }
    end

    # populates the entities for this device. these are in turn used to gather the endpoints
    def populate_entities(options = {})
      include_if_offline = options[:include_offline] || false
      i = 0
      while !(entity_pointer = Map.MIDIDeviceGetEntity(@resource, i)).null?
        @entities << Entity.new(entity_pointer, :include_offline => include_if_offline)
        i += 1
      end
    end

  end

end
