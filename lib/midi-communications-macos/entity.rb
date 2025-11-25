module MIDICommunicationsMacOS
  # A logical grouping of MIDI endpoints within a device.
  #
  # A MIDI entity can have any number of MIDI endpoints, each of which is a
  # {Source source} or {Destination destination} of a 16-channel MIDI stream.
  # By grouping a device's endpoints into entities, the system has enough
  # information for applications to make reasonable default assumptions about
  # bidirectional communication.
  #
  # @see https://developer.apple.com/documentation/coremidi/midientityref
  #
  # @api public
  class Entity
    # @!attribute [r] endpoints
    #   @return [Hash{Symbol => Array<Endpoint>}] endpoints grouped by :source and :destination
    # @!attribute [r] manufacturer
    #   @return [String] device manufacturer name
    # @!attribute [r] model
    #   @return [String] device model name
    # @!attribute [r] name
    #   @return [String] entity name
    # @!attribute [r] resource
    #   @return [FFI::Pointer] pointer to the Core MIDI entity
    attr_reader :endpoints,
                :manufacturer,
                :model,
                :name,
                :resource

    # @param [FFI::Pointer] resource A pointer to the underlying entity
    # @param [Boolean] include_offline Include offline endpoints in the list
    def initialize(resource, include_offline: false)
      @endpoints = {
        source: [],
        destination: []
      }
      @resource = resource
      populate(include_offline: include_offline)
    end

    # Assign all of this Entity's endpoints an consecutive local id
    # @param [Integer] starting_id
    # @return [Integer]
    def populate_endpoint_ids(starting_id)
      counter = 0
      @endpoints.values.flatten.each do |endpoint|
        endpoint.id = counter + starting_id
        counter += 1
      end
      counter
    end

    # Is the entity online?
    # @return [Boolean]
    def online?
      get_int(:offline).zero?
    end

    # Construct a display name for the entity
    # @return [String]
    def display_name
      "#{@manufacturer} #{@model} (#{@name})"
    end

    private

    # Populate endpoints of a specified type for this entity
    # @param [Symbol] type The endpoint type eg :source, :destination
    # @param [Boolean] include_offline Include offline endpoints in the list
    # @return [Integer]
    def populate_endpoints_by_type(type, include_offline:)
      endpoint_class = Endpoint.get_class(type)
      num_endpoints = number_of_endpoints(type)
      (0..num_endpoints).each do |i|
        endpoint = endpoint_class.new(i, self)
        @endpoints[type] << endpoint if endpoint.online? || include_offline
      end
      @endpoints[type].size
    end

    # Populate the endpoints for this entity
    # @param [Boolean] include_offline Include offline endpoints in the list
    # @return [Integer]
    def populate_endpoints(include_offline:)
      @endpoints.keys.map { |type| populate_endpoints_by_type(type, include_offline: include_offline) }.reduce(&:+)
    end

    # The number of endpoints for this entity
    # @param [Symbol] type The endpoint type eg :source, :destination
    def number_of_endpoints(type)
      case type
      when :source then API.MIDIEntityGetNumberOfSources(@resource)
      when :destination then API.MIDIEntityGetNumberOfDestinations(@resource)
      end
    end

    # A CFString property from the underlying entity
    # @param [Symbol, String] name The property name
    # @return [String, nil]
    def get_string(name)
      API.get_string(@resource, name)
    end

    # An Integer property from the underlying entity
    # @param [Symbol, String] name The property name
    # @return [Integer, nil]
    def get_int(name)
      API.get_int(@resource, name)
    end

    # Populate the entity properties from the underlying resource
    # @param [Boolean] include_offline Include offline endpoints in the list
    def populate(include_offline:)
      @manufacturer = get_string(:manufacturer)
      @model = get_string(:model)
      @name = get_string(:name)
      populate_endpoints(include_offline: include_offline)
    end
  end
end
