$LOAD_PATH.prepend(File.expand_path('../lib', __dir__))

require 'minitest/autorun'
require 'shoulda-context'

require 'midi-communications-macos'

# Tests for inline documentation examples
# Note: Most MIDI operations require actual hardware devices.
# These tests verify the examples that don't require hardware.
class MIDICommunicationsMacOS::InlineDocTest < Minitest::Test
  context 'TypeConversion documentation examples' do
    context '#numeric_bytes_to_hex_string' do
      should 'convert Note On bytes to hex string (from @example)' do
        result = MIDICommunicationsMacOS::TypeConversion.numeric_bytes_to_hex_string([0x90, 0x40, 0x40])
        assert_equal '904040', result
      end

      should 'convert Note Off bytes to hex string' do
        result = MIDICommunicationsMacOS::TypeConversion.numeric_bytes_to_hex_string([0x80, 0x40, 0x40])
        assert_equal '804040', result
      end

      should 'pad single digit hex values with zero' do
        result = MIDICommunicationsMacOS::TypeConversion.numeric_bytes_to_hex_string([0x90, 0x01, 0x0F])
        assert_equal '90010F', result
      end

      should 'handle empty array' do
        result = MIDICommunicationsMacOS::TypeConversion.numeric_bytes_to_hex_string([])
        assert_equal '', result
      end

      should 'convert SysEx message' do
        result = MIDICommunicationsMacOS::TypeConversion.numeric_bytes_to_hex_string([0xF0, 0x41, 0xF7])
        assert_equal 'F041F7', result
      end
    end
  end

  context 'Module structure' do
    should 'have Source class' do
      assert defined?(MIDICommunicationsMacOS::Source)
    end

    should 'have Destination class' do
      assert defined?(MIDICommunicationsMacOS::Destination)
    end

    should 'have Device class' do
      assert defined?(MIDICommunicationsMacOS::Device)
    end

    should 'have Entity class' do
      assert defined?(MIDICommunicationsMacOS::Entity)
    end

    should 'have Endpoint module' do
      assert defined?(MIDICommunicationsMacOS::Endpoint)
    end

    should 'have TypeConversion module' do
      assert defined?(MIDICommunicationsMacOS::TypeConversion)
    end

    should 'have API module' do
      assert defined?(MIDICommunicationsMacOS::API)
    end

    should 'have VERSION constant' do
      assert defined?(MIDICommunicationsMacOS::VERSION)
      assert_kind_of String, MIDICommunicationsMacOS::VERSION
    end
  end

  context 'Source class methods' do
    should 'respond to first' do
      assert MIDICommunicationsMacOS::Source.respond_to?(:first)
    end

    should 'respond to last' do
      assert MIDICommunicationsMacOS::Source.respond_to?(:last)
    end

    should 'respond to all' do
      assert MIDICommunicationsMacOS::Source.respond_to?(:all)
    end
  end

  context 'Source instance methods' do
    should 'define gets method' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:gets)
    end

    should 'define gets_s method' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:gets_s)
    end

    should 'define open/enable method' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:open)
      assert MIDICommunicationsMacOS::Source.method_defined?(:enable)
    end

    should 'define close method' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:close)
    end

    should 'define read alias' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:read)
    end

    should 'define gets_bytestr alias' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:gets_bytestr)
    end
  end

  context 'Destination class methods' do
    should 'respond to first' do
      assert MIDICommunicationsMacOS::Destination.respond_to?(:first)
    end

    should 'respond to last' do
      assert MIDICommunicationsMacOS::Destination.respond_to?(:last)
    end

    should 'respond to all' do
      assert MIDICommunicationsMacOS::Destination.respond_to?(:all)
    end
  end

  context 'Destination instance methods' do
    should 'define puts method' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:puts)
    end

    should 'define puts_s method' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:puts_s)
    end

    should 'define puts_bytes method' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:puts_bytes)
    end

    should 'define open/enable method' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:open)
      assert MIDICommunicationsMacOS::Destination.method_defined?(:enable)
    end

    should 'define close method' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:close)
    end

    should 'define write alias' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:write)
    end

    should 'define puts_bytestr alias' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:puts_bytestr)
    end

    should 'define puts_hex alias' do
      assert MIDICommunicationsMacOS::Destination.method_defined?(:puts_hex)
    end
  end

  context 'Device class methods' do
    should 'respond to all' do
      assert MIDICommunicationsMacOS::Device.respond_to?(:all)
    end

    should 'respond to refresh' do
      assert MIDICommunicationsMacOS::Device.respond_to?(:refresh)
    end
  end

  context 'Endpoint module' do
    should 'respond to sources' do
      assert MIDICommunicationsMacOS::Endpoint.respond_to?(:sources)
    end

    should 'respond to destinations' do
      assert MIDICommunicationsMacOS::Endpoint.respond_to?(:destinations)
    end

    should 'respond to all' do
      assert MIDICommunicationsMacOS::Endpoint.respond_to?(:all)
    end

    should 'respond to all_by_type' do
      assert MIDICommunicationsMacOS::Endpoint.respond_to?(:all_by_type)
    end
  end

  context 'Endpoint instance methods (via Source)' do
    should 'define enabled? method' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:enabled?)
    end

    should 'define online? method' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:online?)
    end

    should 'define manufacturer delegator' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:manufacturer)
    end

    should 'define model delegator' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:model)
    end

    should 'define name delegator' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:name)
    end

    should 'define display_name delegator' do
      assert MIDICommunicationsMacOS::Source.method_defined?(:display_name)
    end
  end
end
