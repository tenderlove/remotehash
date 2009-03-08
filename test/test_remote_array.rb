require "test/unit"
require "remotearray"
require 'logger'

class TestRemoteArray < Test::Unit::TestCase
  OPENDHT_URI = "http://openlookup.appspot.com/"
  #OPENDHT_URI = "http://any.openlookup.net:5851/"
  #OPENDHT_URI = "http://planetlab11.Millennium.Berkeley.EDU:5851/"

  def test_new
    assert ary = RemoteArray.new
  end

  def test_push
    ary = RemoteArray.new(Time.now.to_i, Time.now.to_i, OPENDHT_URI)
    ary.push('foo')
    assert_equal 1, ary.length
  end

  def test_to_a
    ary = RemoteArray.new(Time.now.to_i, Time.now.to_i, OPENDHT_URI)
    ary.push('foo')
    ary.push('bar')
    assert_equal %w{ foo bar }, ary.to_a
  end

  def test_pop
    ary = RemoteArray.new(Time.now.to_i, Time.now.to_i, OPENDHT_URI)
    ary.push('foo')
    ary.push('bar')
    assert_equal 'bar', ary.pop
    assert_equal %w{ foo }, ary.to_a
  end
end
