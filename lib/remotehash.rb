require 'uri'
require 'xmlrpc/client'
require 'digest/sha1'
require 'logger'
require 'remotearray'

###
# RemoteHash is a simple OpenDHT client. It lets you store simple hashes on
# a remote server.
#
# Example:
#
#   h1 = RemoteHash.new('hello world')
#   h2 = RemoteHash.new('hello world')
#
#   # Set a key in one hash
#   h1['foo'] = 'bar'
#
#   # Fetch it in another
#   assert_equal 'bar', h2['foo']
#
# For more information on OpenDHT, see http://opendht.org/
class RemoteHash
  VERSION = '1.0.0'
  OPENDHT_URI = "http://openlookup.appspot.com/"

  attr_reader :debug_output
  attr_accessor :secret

  ###
  # Create a new RemoteHash with +secret+ on +uri+ server.
  # Any RemoteHash created with +secret+ has access to the same data that
  # another RemoteHash with the same +secret+ has.  Thus, two RemoteHash
  # instances with the same +secret+ are considered to be equal.
  def initialize secret = Time.now.to_f, uri = OPENDHT_URI
    @uri  = uri
    uri   = URI.parse(@uri)

    @rpc = XMLRPC::Client.new3(
      :host => uri.host,
      :port => uri.port,
      :path => uri.path
    )
    @secret       = secret.to_s
    @internal_hash = Hash.new { |h,k|
      h[k] = RemoteArray.new(k, @secret, @uri)
    }
    self.debug_output = nil
    self.debug_output = Logger.new($stdout) if $DEBUG
  end

  ###
  # Set a debugger to see the server interaction.
  def debug_output= logger
    @debug_output = logger
    @rpc.instance_eval("@http").set_debug_output logger
  end

  ###
  # Set +key+ to +value+
  def []= key, value
    @internal_hash[key].push value
    value
  end

  ###
  # Get the value for +key+
  def [] key
    @internal_hash[key].last
  end

  ###
  # Delete +key+ from the hash.
  def delete key
    @internal_hash[key].clear
  end

  ###
  # Compare this RemoteHash to +other+.  If the two have the same
  # RemoteHash#secret, they are considered equal.
  def == other
    return false unless other.is_a?(RemoteHash)
    secret == other.secret
  end
end
