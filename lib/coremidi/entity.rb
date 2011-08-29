#!/usr/bin/env ruby

module CoreMIDI

  module Entity

    attr_reader :endpoints, 
                :is_online,
                :manufacturer,
                :model,
                :name,
                :pointer
                
    alias_method :online?, :is_online

    def initialize(resource, options = {}, &block)
      @endpoints = { :input => [], :output => [] }
      @resource = resource
      @manufacturer = get_property(:manufacturer)
      @model = get_property(:model)
      @name = "#{@manufacturer} #{@model}"
      @is_online = get_property(:offline, :type => :int) == 0
    end
    
    # assign all of this Entity's endpoints an consecutive id
    def populate_endpoint_ids(starting_id)
      i = nil
      @endpoints.values.flatten.each_with_index do |e, i|  
        e.id = (i + starting_id)
      end
      i
    end
    
    private
    
    # populate endpoints for this device
    def populate_endpoints(type, options = {})
      include_if_offline = options[:include_offline] || false
      endpoint_type, endpoint_class = *case type
        when :input then [:source, Input]
        when :output then [:destination, Output]
      end  
      num_endpoints = number_of_endpoints(endpoint_type, @resource)
      (0..num_endpoints).each do |i|
        ep = endpoint_class.new(i, @resource)
        @endpoints[type] << ep if ep.online? || include_if_offline
      end  
      @endpoints[type].size   
    end
    
    # gets the number of endpoints for this device
    def number_of_endpoints(type)
      case type
        when :source then Map.MIDIEntityGetNumberOfSources(@resource)
        when :destination then Map.MIDIEntityGetNumberOfDestinations(@resource)
      end
    end
    
    # gets a CFString property
    def get_string(name, pointer)
      prop = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 )
      val = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 ) # placeholder
      Map::MIDIObjectGetStringProperty(pointer, prop, val)
      Map::CF.CFStringGetCStringPtr(val.read_pointer, 0).read_string rescue nil
    end
    
    # gets an Integer property
    def get_int(name, pointer)
      prop = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 )
      val = FFI::MemoryPointer.new(:pointer, 32)
      Map::MIDIObjectGetIntegerProperty(pointer, prop, val)
      val.read_int
    end        

    # gets a property from this endpoint's entity
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
