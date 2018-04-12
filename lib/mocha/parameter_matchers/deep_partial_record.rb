require 'mocha/parameter_matchers/base'

module Mocha
  module ParameterMatchers
    # @example
    #   a = {
    #     foo: {
    #       bar: [1, 2]
    #     }
    #   }
    #
    #   b = {
    #     foo: {
    #       bar: [1, 2, 3]
    #     },
    #     baz: 'qux'
    #   }
    #
    #   object = mock()
    #   object.expects(:method_1).with(deep_partial_record(a))
    #   object.method_1(b)
    #   # no error raised
    #
    # @see test/meta/deep_partial_record_test.rb
    def deep_partial_record(o)
      DeepPartialRecord.new(o)
    end

    class DeepPartialRecord < Base
      def initialize(partial)
        @partial = partial
      end

      # @private
      def matches?(available_parameters)
        parameter = available_parameters.shift
        _matches?(@partial, parameter)
      end

      # @private
      private def _matches?(partial, other)
        case partial
        when ::Mocha::ParameterMatchers::Base
          partial.to_matcher.matches?([other])
        when Hash
          Hash === other && partial.all? { |k, v| other.key?(k) && _matches?(v, other[k]) }
        when Enumerable
          Enumerable === other && partial.zip(other).all? { |a, b| _matches?(a, b) }
        else
          partial == other
        end
      end

      # @private
      def mocha_inspect
        "deep_partial_record(#{@partial.mocha_inspect})"
      end
    end
  end
end


module Mocha

  module ParameterMatchers

    # Matches +Hash+ containing all +entries+.
    #
    # @param [Hash] entries expected +Hash+ entries.
    # @return [HasEntries] parameter matcher.
    #
    # @see Expectation#with
    #
    # @example Actual parameter contains all expected entries.
    #   object = mock()
    #   object.expects(:method_1).with(has_entries('key_1' => 1, 'key_2' => 2))
    #   object.method_1('key_1' => 1, 'key_2' => 2, 'key_3' => 3)
    #   # no error raised
    #
    # @example Actual parameter does not contain all expected entries.
    #   object = mock()
    #   object.expects(:method_1).with(has_entries('key_1' => 1, 'key_2' => 2))
    #   object.method_1('key_1' => 1, 'key_2' => 99)
    #   # error raised, because method_1 was not called with Hash containing entries: 'key_1' => 1, 'key_2' => 2
    def has_entries(entries)
      HasEntries.new(entries)
    end

    # Parameter matcher which matches when actual parameter contains all expected +Hash+ entries.
    class HasEntries < Base

      # @private
      def initialize(entries)
        @entries = entries
      end

      # @private
      def matches?(available_parameters)
        parameter = available_parameters.shift
        has_entry_matchers = @entries.map { |key, value| HasEntry.new(key, value) }
        AllOf.new(*has_entry_matchers).matches?([parameter])
      end

      # @private
      def mocha_inspect
        "has_entries(#{@entries.mocha_inspect})"
      end

    end

  end

end
