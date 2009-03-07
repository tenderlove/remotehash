require "test/unit"
require "remotehash"

class TestRemoteHash < Test::Unit::TestCase
  def test_new
    assert RemoteHash.new
  end

  def test_keys
    hash = RemoteHash.new
    hash['foo'] = 'bar'
    assert_equal 'bar', hash['foo']
  end
end
