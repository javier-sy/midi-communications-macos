module CoreMIDI

  module Utility

    def self.device_name(name = "name", resource)
      prop = Map::CF.CFStringCreateWithCString( nil, name.to_s, 0 )

      begin
        name_ptr = FFI::MemoryPointer.new(:pointer)
        Map::MIDIObjectGetStringProperty(resource, prop, name_ptr)
        name = name_ptr.read_pointer
        len = Map::CF.CFStringGetMaximumSizeForEncoding(Map::CF.CFStringGetLength(name), :kCFStringEncodingUTF8)

        bytes = FFI::MemoryPointer.new(len + 1)

        if Map::CF.CFStringGetCString(name, bytes, len + 1, :kCFStringEncodingUTF8)
          bytes.read_string.force_encoding('utf-8')
        else
          nil
        end
      ensure
        Map::CF.CFRelease(name) unless name.nil? || name.null?
        Map::CF.CFRelease(prop) unless prop.null?
      end
    end

  end

end
