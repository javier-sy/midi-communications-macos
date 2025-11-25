module MIDICommunicationsMacOS
  # MIDI output endpoint for sending MIDI messages.
  #
  # A Destination represents a MIDI output that can send messages to
  # external MIDI devices or software. Messages can be sent as numeric
  # bytes, hex strings, or arrays.
  #
  # @example Send a Note On/Off sequence
  #   output = MIDICommunicationsMacOS::Destination.first
  #   output.open
  #   output.puts(0x90, 60, 100)  # Note On, middle C, velocity 100
  #   sleep(0.5)
  #   output.puts(0x80, 60, 0)    # Note Off
  #
  # @example Send as hex string
  #   output.puts_s("903C64")     # Note On
  #   output.puts_s("803C00")     # Note Off
  #
  # @see Source For receiving MIDI messages
  # @see Endpoint For shared endpoint functionality
  #
  # @api public
  class Destination
    include Endpoint

    attr_reader :entity

    # Closes this output.
    #
    # @return [Boolean] true if closed, false if already closed
    def close
      if @enabled
        @enabled = false
        true
      else
        false
      end
    end

    # Sends a MIDI message as a hex string.
    #
    # @param data [String] hex string (e.g., "904040" for Note On)
    # @return [Boolean] true on success
    #
    # @example
    #   output.puts_s("904060")  # Note On
    #   output.puts_s("804060")  # Note Off
    def puts_s(data)
      data = data.dup
      bytes = []
      until (str = data.slice!(0, 2)).eql?('')
        bytes << str.hex
      end
      puts_bytes(*bytes)
      true
    end
    alias puts_bytestr puts_s
    alias puts_hex puts_s

    # Sends a MIDI message as numeric bytes.
    #
    # @param data [Integer] numeric bytes (e.g., 0x90, 0x40, 0x40)
    # @return [Boolean] true on success
    #
    # @example
    #   output.puts_bytes(0x90, 0x40, 0x40)  # Note On
    def puts_bytes(*data)
      type = sysex?(data) ? :sysex : :small
      bytes = API.get_midi_packet(data)
      send("puts_#{type.to_s}", bytes, data.size)
      true
    end

    # Sends a MIDI message in any supported format.
    #
    # Accepts multiple formats:
    # - Numeric bytes: `puts(0x90, 0x40, 0x40)`
    # - Array of bytes: `puts([0x90, 0x40, 0x40])`
    # - Hex string: `puts("904040")`
    #
    # @param args [Array<Integer>, Array<String>, Integer, String] MIDI data
    # @return [Boolean] true on success
    #
    # @example Send as bytes
    #   output.puts(0x90, 60, 100)
    #
    # @example Send as array
    #   output.puts([0x90, 60, 100])
    #
    # @example Send as hex string
    #   output.puts("903C64")
    def puts(*args)
      case args.first
      when Array then args.each { |arg| puts(*arg) }
      when Integer then puts_bytes(*args)
      when String then puts_bytestr(*args)
      end
    end
    alias write puts

    # Opens this output for use.
    #
    # When a block is given, the output is automatically closed when
    # the block exits.
    #
    # @yield [destination] optional block to execute with the open output
    # @yieldparam destination [Destination] self
    # @return [Destination] self
    #
    # @example Open with automatic close
    #   output.open do |o|
    #     o.puts(0x90, 60, 100)
    #   end
    def enable
      @enabled ||= true
      if block_given?
        begin
          yield(self)
        ensure
          close
        end
      end
      self
    end
    alias open enable
    alias start enable

    # Returns the first available output endpoint.
    #
    # @return [Destination] the first destination
    #
    # @example
    #   output = MIDICommunicationsMacOS::Destination.first
    def self.first
      Endpoint.first(:destination)
    end

    # Returns the last available output endpoint.
    #
    # @return [Destination] the last destination
    def self.last
      Endpoint.last(:destination)
    end

    # Returns all available output endpoints.
    #
    # @return [Array<Destination>] all destinations
    #
    # @example
    #   outputs = MIDICommunicationsMacOS::Destination.all
    #   outputs.each { |o| puts o.display_name }
    def self.all
      Endpoint.all_by_type[:destination]
    end

    protected

    # Base initialization for this endpoint -- done whether or not the endpoint is enabled to
    # check whether it is truly available for use
    # @return [Boolean]
    def connect
      client_error = enable_client
      port_error = initialize_port
      @resource = API.MIDIEntityGetDestination(@entity.resource, @resource_id)
      !@resource.address.zero? && client_error.zero? && port_error.zero?
    end
    alias connect? connect

    private

    # Output a short MIDI message
    def puts_small(bytes, size)
      packet_list = API.get_midi_packet_list(bytes, size)
      API.MIDISend(@handle, @resource, packet_list)
      true
    end

    # Output a System Exclusive MIDI message
    def puts_sysex(bytes, size)
      request = API::MIDISysexSendRequest.new
      request[:destination] = @resource
      request[:data] = bytes
      request[:bytes_to_send] = size
      request[:complete] = 0
      request[:completion_proc] = SysexCompletionCallback
      request[:completion_ref_con] = request
      API.MIDISendSysex(request)
      true
    end

    SysexCompletionCallback =
      API.get_callback([:pointer]) do |sysex_request_ptr|
      # this isn't working for some reason. as of now, it's not needed though
      end

    # Initialize a midi-communications-macos port for this endpoint
    def initialize_port
      port = API.create_midi_output_port(@client, @resource_id, @name)
      @handle = port[:handle]
      port[:error]
    end

    # Is the given data a MIDI sysex message?
    def sysex?(data)
      data.first.eql?(0xF0) && data.last.eql?(0xF7)
    end
  end
end
