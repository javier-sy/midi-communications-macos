module MIDICommunicationsMacOS
  # Represents a physical or virtual MIDI device.
  #
  # A MIDI device may have multiple logically distinct sub-components. For example,
  # one device may encompass a MIDI synthesizer and a pair of MIDI ports, both
  # addressable via a USB port. Each such element of a device is called an {Entity}.
  #
  # Devices contain {Entity entities}, which in turn contain {Endpoint endpoints}
  # ({Source sources} and {Destination destinations}).
  #
  # @example List all devices
  #   MIDICommunicationsMacOS::Device.all.each do |device|
  #     puts device.name
  #   end
  #
  # @see https://developer.apple.com/documentation/coremidi/midideviceref
  #
  # @api public
  class Device
    # @!attribute [r] entities
    #   @return [Array<Entity>] the device's entities
    # @!attribute [r] id
    #   @return [Integer] unique numeric ID
    # @!attribute [r] name
    #   @return [String] device name from Core MIDI
    attr_reader :entities,
                :id,
                :name

    # Creates a new Device wrapper.
    #
    # @param id [Integer] the device ID
    # @param device_pointer [FFI::Pointer] pointer to the Core MIDI device
    # @param include_offline [Boolean] whether to include offline entities
    # @api private
    def initialize(id, device_pointer, include_offline: false)
      @id = id
      @resource = device_pointer
      @entities = []
      populate(include_offline: include_offline)
    end

    # Returns all endpoints for this device, grouped by type.
    #
    # @return [Hash{Symbol => Array<Endpoint>}] hash with :source and :destination keys
    def endpoints
      endpoints = { source: [], destination: [] }
      endpoints.each_key do |key|
        endpoint_group = entities.map { |entity| entity.endpoints[key] }.flatten
        endpoints[key] += endpoint_group
      end
      endpoints
    end

    # Assign all of this Device's endpoints an consecutive local id
    # @param [Integer] last_id The highest already used endpoint ID
    # @return [Integer] The highest used endpoint ID after populating this device's endpoints
    def populate_endpoint_ids(last_id)
      id = 0
      entities.each { |entity| id += entity.populate_endpoint_ids(id + last_id) }
      id
    end

    # Returns all available MIDI devices.
    #
    # Devices are cached by default. Use `cache: false` to refresh, or call
    # {.refresh} to clear the cache.
    #
    # @param options [Hash] options for device selection
    # @option options [Boolean] :cache (true) whether to use cached devices
    # @option options [Boolean] :include_offline (false) include offline devices
    # @return [Array<Device>] all available devices
    #
    # @example
    #   devices = MIDICommunicationsMacOS::Device.all
    #   devices.each { |d| puts d.name }
    def self.all(options = {})
      use_cache = options[:cache] || true
      include_offline = options[:include_offline] || false
      if !populated? || !use_cache
        @devices = []
        counter = 0
        while !(device_pointer = API.MIDIGetDevice(counter)).null?
          device = new(counter, device_pointer, include_offline: include_offline)
          @devices << device
          counter += 1
        end
        populate_endpoint_ids
      end
      @devices
    end

    # Clears the device cache.
    #
    # Call this when MIDI devices are plugged in or unplugged while the
    # program is running, then call {.all} to get the updated list.
    #
    # @return [Array<Device>] the cleared cache (empty array)
    def self.refresh
      @devices.clear
      @devices
    end

    # Has the device list been populated?
    def self.populated?
      defined?(@devices) && !@devices.nil? && !@devices.empty?
    end

    private

    # Populate the device name
    def populate_name
      @name = API.get_string(@resource, 'name')
      raise "Can't get device name" unless @name
    end

    # All of the endpoints for all devices a consecutive local id
    def self.populate_endpoint_ids
      counter = 0
      all.each { |device| counter += device.populate_endpoint_ids(counter) }
      counter
    end

    # Populates the entities for this device. These entities are in turn used to gather the endpoints.
    # @param [Hash] options
    # @option options [Boolean] :include_offline Whether to include offline entities (default: false)
    # @return [Integer] The number of entities populated
    def populate_entities(options = {})
      include_if_offline = options[:include_offline] || false
      i = 0
      while !(entity_pointer = API.MIDIDeviceGetEntity(@resource, i)).null?
        @entities << Entity.new(entity_pointer, include_offline: include_if_offline)
        i += 1
      end
      i
    end

    # Populate the instance
    def populate(include_offline:)
      populate_name
      populate_entities(include_offline: include_offline)
    end
  end
end
