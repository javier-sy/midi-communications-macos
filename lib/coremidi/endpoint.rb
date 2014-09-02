module CoreMIDI

  module Endpoint
    
    extend Forwardable

    attr_reader :enabled, # has the endpoint been initialized?
                :entity, # unique local Numeric id of the endpoint
                :id,
                :resource_id, # :input or :output
                :type
                
    def_delegators :entity, :manufacturer, :model, :name

    alias_method :enabled?, :enabled

    def initialize(resource_id, entity, options = {}, &block)
      @entity = entity
      @resource_id = resource_id
      @type = self.class.name.split('::').last.downcase.to_sym
      @enabled = false
    end
    
    # Is this endpoint online?
    # @return [Boolean]
    def online?
      @entity.online? && connect?
    end
    
    # Set the id for this endpoint (the id is immutable)
    # @param [Fixnum] val
    # @return [Fixnum]
    def id=(id)
      @id ||= id
    end

    # Select the first endpoint of the specified type
    # @return [Destination, Source]
    def self.first(type)
      all_by_type[type].first
    end

    # Select the last endpoint of the specified type
    # @return [Destination, Source]
    def self.last(type)
      all_by_type[type].last
    end

    # A Hash of :source and :destination endpoints
    # @return [Hash]
    def self.all_by_type
      {
        :source => Device.all.map { |d| d.endpoints[:source] }.flatten,
        :destination => Device.all.map { |d| d.endpoints[:destination] }.flatten
      }
    end

    # All endpoints of both types
    # @return [Array<Destination, Source>]
    def self.all
      Device.all.map(&:endpoints).flatten
    end

    # Get the class for the given endpoint type name
    # @param [Symbol] type The endpoint type eg :source, :destination
    # @return [Class] eg Source, Destination
    def self.get_class(type)
      case type
      when :source then Source
      when :destination then Destination
      end  
    end
    
    protected
    
    # Enables the coremidi MIDI client that will go with this endpoint
    def enable_client
      client_name = Map::CF.CFStringCreateWithCString(nil, "Client #{@resource_id} #{name}", 0)
      client_ptr = FFI::MemoryPointer.new(:pointer)
      error = Map.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer
      error
    end

  end

end
