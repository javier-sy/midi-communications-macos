#!/usr/bin/env ruby

module CoreMIDI

  module Entity

    attr_reader :is_online,
                :manufacturer,
                :model,
                :name,
                :pointer
                
    alias_method :online?, :is_online

    def initialize(resource, options = {}, &block)
      @resource = resource
      @manufacturer = get_property(:manufacturer)
      @model = get_property(:model)
      @name = "#{@manufacturer} #{@model}"
      @is_online = get_property(:offline, :type => :int) == 0
    end
    
    private
    
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
