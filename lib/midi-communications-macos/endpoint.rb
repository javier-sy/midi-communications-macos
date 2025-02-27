module MIDICommunicationsMacOS
  # A source or destination of a 16-channel MIDI stream
  #
  # https://developer.apple.com/library/ios/documentation/CoreMidi/Reference/MIDIServices_Reference/Reference/reference.html
  module Endpoint
    extend Forwardable

    attr_reader :enabled, # has the endpoint been initialized?
                :entity,
                :id, # unique local Numeric id of the endpoint
                :resource_id, # :input or :output
                :type

    def_delegators :entity, :manufacturer, :model, :name, :display_name

    alias enabled? enabled

    # @param [Integer] resource_id
    # @param [Entity] entity
    def initialize(resource_id, entity)
      @entity = entity
      @resource_id = resource_id
      @type = get_type
      @enabled = false

      @name = nil

      @threads_sync_semaphore = Mutex.new
      @threads_waiting = []
    end

    # Is this endpoint online?
    # @return [Boolean]
    def online?
      @entity.online? && connect?
    end

    # Set the id for this endpoint (the id is immutable)
    # @param [Integer] id
    # @return [Integer]
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

    # All source endpoints
    # @return [Array<Source>]
    def self.sources
      Device.all.map { |d| d.endpoints[:source] }.flatten
    end

    # All destination endpoints
    # @return [Array<Destination>]
    def self.destinations
      Device.all.map { |d| d.endpoints[:destination] }.flatten
    end

    # A Hash of :source and :destination endpoints
    # @return [Hash]
    def self.all_by_type
      {
        source: sources,
        destination: destinations
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

    # Constructs the endpoint type (eg source, destination) for easy consumption
    def get_type
      class_name = self.class.name.split('::').last
      class_name.downcase.to_sym
    end

    # Enables the midi-communications-macos MIDI client that will go with this endpoint
    def enable_client
      client = API.create_midi_client(@resource_id, @name)
      @client = client[:resource]
      client[:error]
    end
  end
end
