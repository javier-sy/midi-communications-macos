module CoreMIDI

  class Entity

    attr_reader :endpoints, 
                :is_online,
                :manufacturer,
                :model,
                :name,
                :resource
                
    alias_method :online?, :is_online

    def initialize(resource, options = {}, &block)
      @endpoints = { 
        :source => [], 
        :destination => [] 
      }
      @resource = resource
      @manufacturer = get_property(:manufacturer)
      @model = get_property(:model)
      @name = get_name
      @is_online = get_property(:offline, :type => :int) == 0
      @endpoints.keys.each { |type| populate_endpoints(type) }
    end
    
    # Assign all of this Entity's endpoints an consecutive local id
    def populate_endpoint_ids(starting_id)
      counter = 0
      @endpoints.values.flatten.each do |endpoint|  
        endpoint.id = (counter + starting_id)
        counter += 1
      end
      counter
    end
    
    private

    # Construct a display name for the entity
    # @return [String]
    def get_name
      "#{@manufacturer} #{@model}"
    end
    
    # Populate endpoints of a specified type for this entity
    def populate_endpoints(type, options = {})
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
    
    # The number of endpoints for this entity
    def number_of_endpoints(type)
      case type
        when :source then Map.MIDIEntityGetNumberOfSources(@resource)
        when :destination then Map.MIDIEntityGetNumberOfDestinations(@resource)
      end
    end
    
    # A CFString property
    def get_string(name, pointer)
      prop = Map::CF.CFStringCreateWithCString(nil, name.to_s, 0)
      val = Map::CF.CFStringCreateWithCString(nil, name.to_s, 0) # placeholder
      Map::MIDIObjectGetStringProperty(pointer, prop, val)
      Map::CF.CFStringGetCStringPtr(val.read_pointer, 0).read_string rescue nil
    end
    
    # An Integer property
    def get_int(name, pointer)
      prop = Map::CF.CFStringCreateWithCString(nil, name.to_s, 0)
      val = FFI::MemoryPointer.new(:pointer, 32)
      Map::MIDIObjectGetIntegerProperty(pointer, prop, val)
      val.read_int
    end        

    # A CString or Integer property from this Endpoint's entity
    def get_property(name, options = {})
      from = options[:from] || @resource
      type = options[:type] || :string
      
      case type
        when :string then get_string(name, from)
        when :int then get_int(name, from)
      end
    end

  end

end
