require File.expand_path('../../../test_helper', __FILE__)

require 'mocha/parameter_matchers/deep_partial_record'
require 'mocha/parameter_matchers/has_entry'
require 'mocha/inspect'

class DeepPartialRecordTest < Mocha::TestCase
  include Mocha::ParameterMatchers

  def test_should_match_iff_every_leaf_value_of_a_is_contained_in_b
    a = {
      foo: {
        bar: [1, 2 ]
      }
    }

    b = {
      foo: {
        bar: [1, 2, 3]
      },
      baz: 'qux'
    }

    matcher = deep_partial_record(a)
    assert matcher.matches?([b])
  end

  def test_should_not_match_if_any_value_of_a_is_not_contained_in_b
    a = {
      foo: {
        bar: [1, 2, 3]
      }
    }

    b = {
      foo: {
        bar: [1, 2]
      }
    }

    matcher = deep_partial_record(a)
    refute matcher.matches?([b])
  end

  def test_correctly_handles_mocha_matchers_nested_within_the_partial_record
    matcher = deep_partial_record({ foo: has_entry(bar: 'baz') })
    assert matcher.matches?([{ foo: { bar: 'baz' } }])
  end

  def test_should_match_non_enumerable_objects_using_simple_equality
    matcher = deep_partial_record("foo")
    assert matcher.matches?(["foo"])
  end
end
