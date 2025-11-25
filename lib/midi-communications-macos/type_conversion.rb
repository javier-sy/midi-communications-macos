module MIDICommunicationsMacOS
  # Utility methods for converting between MIDI data formats.
  #
  # @api public
  module TypeConversion
    extend self

    # Converts an array of numeric bytes to a hex string.
    #
    # @param bytes [Array<Integer>] array of numeric bytes (e.g., [0x90, 0x40, 0x40])
    # @return [String] uppercase hex string (e.g., "904040")
    #
    # @example
    #   TypeConversion.numeric_bytes_to_hex_string([0x90, 0x40, 0x40])
    #   # => "904040"
    def numeric_bytes_to_hex_string(bytes)
      string_bytes = bytes.map do |byte|
        str = byte.to_s(16).upcase
        str = "0#{str}" if byte < 16
        str
      end
      string_bytes.join
    end
  end
end
