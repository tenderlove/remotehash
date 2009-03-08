require 'uri'
require 'xmlrpc/client'
require 'digest/sha1'
require 'logger'

class RemoteArray
  OPENDHT_URI = "http://openlookup.appspot.com/"

  def initialize key = Time.now.to_i, secret = key, uri = OPENDHT_URI

    uri = URI.parse(uri)

    @rpc = XMLRPC::Client.new3(
      :host => uri.host,
      :port => uri.port,
      :path => uri.path
    )
    @secret       = secret.to_s
    @key          = key
    self.debug_output = nil
    self.debug_output = Logger.new($stdout) if $DEBUG
  end

  ###
  # Set a debugger to see the server interaction.
  def debug_output= logger
    @debug_output = logger
    @rpc.instance_eval("@http").set_debug_output logger
  end

  def push value
    retries = 0
    begin
      result = @rpc.call('put_removable',
        XMLRPC::Base64.new(Marshal.dump(@key)),
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
  alias :<< :push

  def pop
    rm(to_a.last)
  end

  def length
    to_a.length
  end

  def last
    to_a.last
  end

  def to_a
    values = []
    placemark = ''

    loop do
      retries = 0
      begin

        result = @rpc.call('get_details',
          XMLRPC::Base64.new(Marshal.dump(@key)),
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
    }.sort_by { |entry| entry[1] }.map { |x| Marshal.load(x.first) }
  end

  def clear
    to_a.each { |v| rm(v) }
  end

  private
  def rm obj
    retries = 0
    begin
      result = @rpc.call('rm',
        XMLRPC::Base64.new(Marshal.dump(@key)),
        XMLRPC::Base64.new(Digest::SHA1.digest(Marshal.dump(obj))),
        'SHA',
        XMLRPC::Base64.new(@secret),
        3610,
        'remotehash'
      )
      raise if result == 1
    rescue Timeout::Error => e
      raise(e) if retries == 4
      retries += 1
      retry
    end
    obj
  end
end
