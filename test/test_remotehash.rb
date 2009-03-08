require "test/unit"
require "remotehash"
require 'logger'

class TestRemoteHash < Test::Unit::TestCase
  OPENDHT_URI = "http://openlookup.appspot.com/"
  #OPENDHT_URI = "http://any.openlookup.net:5851/"
  #OPENDHT_URI = "http://planetlab1.cs.uoregon.edu:5851/"

  def test_new
    assert RemoteHash.new
  end

  def test_debug_output=
    assert hash = RemoteHash.new
    hash.debug_output = Logger.new($stdout)
  end

  def test_key_access
    hash = RemoteHash.new(Time.now.to_f, OPENDHT_URI)

    hash['foo'] = 'baz'
    assert_equal 'baz', hash['foo']
  end

  def test_two_instances
    h1 = RemoteHash.new(Time.now.to_f, OPENDHT_URI)
    h2 = RemoteHash.new(Time.now.to_f, OPENDHT_URI)

    h1['foo'] = 'bar'
    assert_nil h2['foo']
  end

  def test_array_as_value
    h1 = RemoteHash.new(Time.now.to_f, OPENDHT_URI)
    h1['foo'] = %w{ bar baz }
    assert_equal %w{ bar baz }, h1['foo']
  end

  def test_array_as_key
    h1 = RemoteHash.new(Time.now.to_f, OPENDHT_URI)
    h1[%w{ foo }] = %w{ bar baz }
    assert_equal %w{ bar baz }, h1[%w{ foo }]
  end

  def test_delete
    h1 = RemoteHash.new(Time.now.to_f, OPENDHT_URI)
    h1['foo'] = 'bar'
    h1.delete('foo')
    assert_nil h1['foo']
  end

  def test_equal_keys
    h1 = RemoteHash.new('hello world')
    h2 = RemoteHash.new('hello world')
    h1['foo'] = 'bar'
    assert_equal 'bar', h2['foo']
  end

  def test_equals
    h1 = RemoteHash.new('hello world')
    h2 = RemoteHash.new('hello world')
    assert_equal h1, h2
  end
end
