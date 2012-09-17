require 'vidocq/connection'
require 'vidocq/caching_connection'

module Vidocq

  class NoEndpointError < StandardError; end
  class NoResponseError < StandardError; end

  def self.new(connect_string = nil)
    Connection.new(connect_string)
  end

  def self.cached(service_id, version, connect_string = nil)
    Connection.new(connect_string).cached(service_id, version)
  end

end
