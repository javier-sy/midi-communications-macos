module CoreMIDI

  class Device

    attr_reader :entities,
                :id, # Unique Numeric id
                :name # Device name from coremidi

    # @param [Fixnum] id The ID for the device
    # @
    def initialize(id, device_pointer, options = {})
      include_if_offline = options.fetch(:include_offline, false)
      @id = id
      @resource = device_pointer
      @entities = []
      populate_name
      populate_entities(:include_offline => include_if_offline)
    end
            
    # Endpoints for this device
    # @return [Array<Endpoint>]
    def endpoints
      endpoints = { :source => [], :destination => [] }
      endpoints.keys.each do |key|
        endpoint_group = entities.map { |entity| entity.endpoints[key] }.flatten
        endpoints[key] += endpoint_group
      end
      endpoints
    end
    
    # Assign all of this Device's endpoints an consecutive local id
    # @param [Integer] last_id The highest already used endpoint ID 
    # @return [Integer] The highest used endpoint ID after populating this device's endpoints
    def populate_endpoint_ids(last_id)
      i = 0
      entities.each { |entity| i += entity.populate_endpoint_ids(i + last_id) }
      i
    end

    # All cached devices
    # @param [Hash] options The options to select devices with
    # @option options [Boolean] :cache If false, the device list will never be cached. This would be useful if one needs to alter the device list (e.g. plug in a USB MIDI interface) while their program is running.
    # @option options [Boolean] :include_offline If true, devices marked offline by coremidi will be included in the list
    # @return [Array<Device>] All cached devices
    def self.all(options = {})
      use_cache = options[:cache] || true
      include_offline = options[:include_offline] || false
      if !populated? || !use_cache
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

    # Refresh the Device cache. This is needed if, for example a USB MIDI device is plugged in while the program is running
    # @return [Array<Device>] The Device cache
    def self.refresh
      @devices.clear
      @devices
    end

    # Has the device list been populated?
    def self.populated?
      !@devices.nil? && !@devices.empty? 
    end

    private

    # Populate the device name
    def populate_name
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
    end
    
    # All of the endpoints for all devices a consecutive local id
    def self.populate_endpoint_ids
      i = 0
      all.each { |device| i += device.populate_endpoint_ids(i) }
      i
    end

    # Populates the entities for this device. These entities are in turn used to gather the endpoints.
    #
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
