#!/usr/bin/env ruby

module CoreMIDI

  module Endpoint

                # has the device been initialized?
    attr_reader :enabled,
                # unique Numeric id of the device
                :id,
                :is_online,
                :manufacturer,
                :model,
                :name,
                # :input or :output
                :type

    alias_method :enabled?, :enabled
    alias_method :online?, :is_online

    def initialize(id, endpoint_id, entity_pointer, options = {}, &block)
      @endpoint_id = endpoint_id
      @entity_pointer = entity_pointer
      @id = id
      @attempt_connect = false

      # cache the type name so that inspecting the class isn't necessary each time
      @type = self.class.name.split('::').last.downcase.to_sym

      @manufacturer = get_property(:manufacturer)
      @model = get_property(:model)
      
      #@subname = get_property(:Name, @endpoint)
      @name = "#{@manufacturer} #{@model}"

      @is_online = get_property(:offline, :type => :int) == 0 && connect?

      @enabled = false
    end

    def enable_client
      client_name = Map::CF.CFStringCreateWithCString( nil, "Client #{@id}: #{@name}", 0 )
      client_ptr = FFI::MemoryPointer.new(:pointer)

      error = Map.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer
      error
    end

    # select the first device of type <em>type</em>
    def self.first(type)
      all_by_type[type].first
    end

    # select the last device of type <em>type</em>
    def self.last(type)
      all_by_type[type].last
    end

    # a Hash of :input and :output devices
    def self.all_by_type
      {
        :input => Device.all.map { |d| d.endpoints[:input] }.flatten,
        :output => Device.all.map { |d| d.endpoints[:output] }.flatten
      }
    end

    # all devices of both types
    def self.all
      Device.all.map { |d| d.endpoints }.flatten
    end

    private
    
    def get_string(name, from)
      prop = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 )
      val = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 ) # placeholder
      Map::MIDIObjectGetStringProperty(from, prop, val)
      Map::CF.CFStringGetCStringPtr(val.read_pointer, 0).read_string rescue nil
    end
    
    def get_int(name, from)
      prop = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 )
      val = FFI::MemoryPointer.new(:pointer, 32)
      Map::MIDIObjectGetIntegerProperty(from, prop, val)
      val.read_int
    end        

    def get_property(name, options = {})
      from = options[:from] || @entity_pointer
      type = options[:type] || :string
      
      case type
        when :string then get_string(name, from)
        when :int then get_int(name, from)
      end
    end

  end

end
