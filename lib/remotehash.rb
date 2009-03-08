require 'uri'
require 'xmlrpc/client'
require 'digest/sha1'
require 'logger'

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

  attr_reader :debug_output
  attr_accessor :secret

  ###
  # Create a new RemoteHash with +secret+ on +uri+ server.
  # Any RemoteHash created with +secret+ has access to the same data that
  # another RemoteHash with the same +secret+ has.  Thus, two RemoteHash
  # instances with the same +secret+ are considered to be equal.
  def initialize secret = Time.now.to_f, uri = "http://opendht.nyuld.net:5851/"
    uri = URI.parse(uri)

    @rpc = XMLRPC::Client.new3(
      :host => uri.host,
      :port => uri.port,
      :path => uri.path
    )
    @secret       = secret.to_s
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
    retries = 0
    begin
      result = @rpc.call('put_removable',
        XMLRPC::Base64.new(Marshal.dump(key)),
        XMLRPC::Base64.new(Marshal.dump(value)),
        'SHA',
        XMLRPC::Base64.new(Digest::SHA1.digest(@secret)),
        3600,
        'remotehash'
      )
      raise "Capacity" if result == 1
    rescue Timeout::Error => e
      raise(e) if retries == 4
      retries += 1
      retry
    end
  end

  ###
  # Get the value for +key+
  def [] key
    value = values_for(key).last.first
    return nil unless value
    Marshal.load(value)
  end

  ###
  # Delete +key+ from the hash.
  def delete key
    values_for(key).each do |value, *rest|
      retries = 0
      begin
        result = @rpc.call('rm',
          XMLRPC::Base64.new(Marshal.dump(key)),
          XMLRPC::Base64.new(Marshal.dump(value)),
          'SHA',
          XMLRPC::Base64.new(Digest::SHA1.digest(@secret)),
          3600,
          'remotehash'
        )
        raise if result == 1
      rescue Timeout::Error => e
        raise(e) if retries == 4
        retries += 1
        retry
      end
    end
  end

  ###
  # Compare this RemoteHash to +other+.  If the two have the same
  # RemoteHash#secret, they are considered equal.
  def == other
    return false unless other.is_a?(RemoteHash)
    secret == other.secret
  end

  private
  def values_for key
    values = []
    placemark = ''

    D 'fetching key'
    loop do
      D 'calling get_details'
      retries = 0
      begin

        result = @rpc.call('get_details',
          XMLRPC::Base64.new(Marshal.dump(key)),
          10,
          XMLRPC::Base64.new(placemark),
          'remotehash'
        )
        values += result.first
        placemark = result.last
        break if placemark == ''

      rescue Timeout::Error => e
        raise e if retries == 4
        retries += 1
        retry
      end
    end

    # Get the newest value with a matching sha1
    values.find_all { |entry|
      entry.last == Digest::SHA1.digest(@secret)
    }.sort_by { |entry| entry[1] } || [[]]
  end

  def D message
    return unless @debug_output
    @debug_output << message
    @debug_output << "\n"
  end
end
