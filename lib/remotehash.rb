require 'uri'
require 'xmlrpc/client'
require 'digest/sha1'

class RemoteHash
  VERSION = '1.0.0'

  def initialize
    uri = URI.parse("http://opendht.nyuld.net:5851/")

    @rpc = XMLRPC::Client.new3(
      :host => uri.host,
      :port => uri.port,
      :path => uri.path
    )
    @secret = ''
  end

  def []= key, value
    result = @rpc.call('put_removable',
      XMLRPC::Base64.new(key),
      XMLRPC::Base64.new(value),
      'SHA',
      XMLRPC::Base64.new(Digest::SHA1.digest(@secret)),
      3600,
      'remotehash'
    )
    redo if result == 2
    raise if result == 1
  end

  def [] key
  end
end
