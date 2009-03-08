require 'uri'
require 'xmlrpc/client'
require 'digest/sha1'
require 'logger'

class RemoteHash
  VERSION = '1.0.0'

  attr_reader :debug_output

  def initialize secret = Time.now.to_f
    uri = URI.parse("http://planetlab1.cs.uoregon.edu:5851/")

    @rpc = XMLRPC::Client.new3(
      :host => uri.host,
      :port => uri.port,
      :path => uri.path
    )
    @secret       = secret.to_s
    self.debug_output = nil
    self.debug_output = Logger.new($stdout) if $DEBUG
  end

  def debug_output= logger
    @debug_output = logger
    @rpc.instance_eval("@http").set_debug_output logger
  end

  def []= key, value
    retries = 0
    begin
      result = @rpc.call('put_removable',
        XMLRPC::Base64.new(key),
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

  def [] key
    values = []
    placemark = ''

    D 'fetching key'
    loop do
      D 'calling get_details'
      retries = 0
      begin

        result = @rpc.call('get_details',
          XMLRPC::Base64.new(key),
          10,
          XMLRPC::Base64.new(placemark),
          'remotehash'
        )
        values += result.first
        placemark = result.last
        break if placemark == ''

      rescue Timeout::Error => e
        raise(e) if retries == 4
        retries += 1
        retry
      end
    end

    # Get the newest value with a matching sha1
    value = (values.sort_by { |entry| entry[1] }.reverse.find { |entry|
      entry.last == Digest::SHA1.digest(@secret)
    } || []).first
    return nil unless value
    Marshal.load(value)
  end

  private
  def D message
    return unless @debug_output
    @debug_output << message
    @debug_output << "\n"
  end
end
