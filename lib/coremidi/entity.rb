module CoreMIDI

  class Entity

    attr_reader :endpoints, 
                :is_online,
                :manufacturer,
                :model,
                :name,
                :resource
                
    # @param [FFI::Pointer] resource A pointer to the underlying entity
    # @param [Hash] options
    def initialize(resource, options = {}, &block)
      @endpoints = { 
        :source => [], 
        :destination => [] 
      }
      @resource = resource
      populate
    end
    
    # Assign all of this Entity's endpoints an consecutive local id
    # @param [Fixnum] starting_id
    # @return [Fixnum]
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
      get_property(:offline, :type => :int) == 0
    end

    private

    # Construct a display name for the entity
    # @return [String]
    def get_name
      "#{@manufacturer} #{@model}"
    end
    
    # Populate endpoints of a specified type for this entity
    # @param [Symbol] type The endpoint type eg :source, :destination
    # @param [Hash] options
    # @option options [Boolean] :include_offline Include offline endpoints in the list
    # @return [Fixnum]
    def populate_endpoints_by_type(type, options = {})
      endpoint_class = Endpoint.get_class(type)
      num_endpoints = number_of_endpoints(type)
      (0..num_endpoints).each do |i|
        endpoint = endpoint_class.new(i, self)
        if endpoint.online? || options[:include_offline]
          @endpoints[type] << endpoint
        end
      end  
      @endpoints[type].size   
    end

    # Populate the endpoints for this entity
    # @return [Fixnum]
    def populate_endpoints
      @endpoints.keys.map { |type| populate_endpoints_by_type(type) }.reduce(&:+)
    end
    
    # The number of endpoints for this entity
    # @param [Symbol] type The endpoint type eg :source, :destination
    def number_of_endpoints(type)
      case type
        when :source then Map.MIDIEntityGetNumberOfSources(@resource)
        when :destination then Map.MIDIEntityGetNumberOfDestinations(@resource)
      end
    end
    
    # A CFString property from the underlying entity
    # @param [Symbol, String] name The property name
    # @return [String, nil]
    def get_string(name)
      Map.get_string(@resource, name)
    end
    
    # An Integer property from the underlying entity
    # @param [Symbol, String] name The property name
    # @return [Fixnum, nil]
    def get_int(name)
      property = Map::CF.CFStringCreateWithCString(nil, name.to_s, 0)
      value = FFI::MemoryPointer.new(:pointer, 32)
      Map::MIDIObjectGetIntegerProperty(@resource, property, value)
      value.read_int
    end        

    # A CString or Integer property from the underlying entity
    # @param [Symbol, String] name The property name
    # @param [Hash] options
    # @option options [Symbol] :type The property type eg :int, :string (default :string)
    # @return [Fixnum, String, nil]
    def get_property(name, options = {})
      case options[:type]
        when :string, nil then get_string(name)
        when :int then get_int(name)
      end
    end

    # Populate the entity properties from the underlying resource
    def populate
      @manufacturer = get_property(:manufacturer)
      @model = get_property(:model)
      @name = get_name
      populate_endpoints
    end

  end

end
