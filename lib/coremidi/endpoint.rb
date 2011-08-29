#!/usr/bin/env ruby

module CoreMIDI

  module Endpoint

                # has the device been initialized?
    attr_reader :enabled,
                :entity,
                # unique Numeric id of the device
                :id,
                :is_online,
                :resource_id,
                # :input or :output
                :type
                
    def_delegators :entity, :manufacturer, :model, :name

    alias_method :enabled?, :enabled
    alias_method :online?, :is_online

    def initialize(resource_id, entity, options = {}, &block)
      @entity = entity
      @resource_id = resource_id
      @type = self.class.name.split('::').last.downcase.to_sym
      @is_online = @entity.online? && connect?
      @enabled = false
    end
    
    # sets the id for this endpoint (the id is immutable once its set)
    def id=(val)
      @id ||= val
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
    
    protected
    
    # enables the coremidi MIDI client that will go with this endpoint
    def enable_client
      client_name = Map::CF.CFStringCreateWithCString( nil, "Client #{@resource_id} #{name}", 0 )
      client_ptr = FFI::MemoryPointer.new(:pointer)
      error = Map.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer
      error
    end

  end

end
