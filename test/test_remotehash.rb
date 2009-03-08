require "test/unit"
require "remotehash"
require 'logger'

class TestRemoteHash < Test::Unit::TestCase
  def test_new
    assert RemoteHash.new
  end

  def test_debug_output=
    assert hash = RemoteHash.new
    hash.debug_output = Logger.new($stdout)
  end

  def test_keys
    hash = RemoteHash.new

    hash['foo'] = 'baz'
    assert_equal 'baz', hash['foo']
  end

  def test_two_instances
    h1 = RemoteHash.new
    h2 = RemoteHash.new

    h1['foo'] = 'bar'
    assert_nil h2['foo']
  end

  def test_array_as_value
    h1 = RemoteHash.new
    h1['foo'] = %w{ bar baz }
    assert_equal %w{ bar baz }, h1['foo']
  end

  def test_array_as_key
    h1 = RemoteHash.new
    h1[%w{ foo }] = %w{ bar baz }
    assert_equal %w{ bar baz }, h1[%w{ foo }]
  end
end
