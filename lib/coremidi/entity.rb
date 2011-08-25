#!/usr/bin/env ruby

module CoreMIDI

  module Entity

                # has the device been initialized?
    attr_reader :enabled,
                # unique Numeric id of the device
                :id,
                :manufacturer,
                :model,
                :name,
                # :input or :output
                :type

    alias_method :enabled?, :enabled

    def initialize(id, endpoint_id, entity_pointer, options = {}, &block)
      @endpoint_id = endpoint_id
      @entity_pointer = entity_pointer
      @id = id

      # cache the type name so that inspecting the class isn't necessary each time
      @type = self.class.name.split('::').last.downcase.to_sym

      @manufacturer = get_property(:manufacturer)
      @model = get_property(:model)
      @online = get_property(:offline)
      #@subname = get_property(:Name, @endpoint)
      @name = "#{@manufacturer} #{@model}"

      @enabled = false
    end

    def enable_entity
      client_name = Map::CF.CFStringCreateWithCString( nil, "Client #{@id}: #{@name}", 0 )
      client_ptr = FFI::MemoryPointer.new(:pointer)

      Map.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer
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
        :input => Device.all.map { |d| d.entities[:input] }.flatten,
        :output => Device.all.map { |d| d.entities[:output] }.flatten
      }
    end

    # all devices of both types
    def self.all
      Device.all.map { |d| d.entities }.flatten
    end

    private

    def get_property(name, from = @entity_pointer)
      prop = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 )
      val = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 ) # placeholder
      Map::MIDIObjectGetStringProperty(from, prop, val)
      Map::CF.CFStringGetCStringPtr(val.read_pointer, 0).read_string rescue nil
    end

  end

end
