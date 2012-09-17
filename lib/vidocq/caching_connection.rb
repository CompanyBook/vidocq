require 'httparty'
require 'json'

module Vidocq
  class CachingConnection
    def initialize(service_id, version, connection)
      @service_id = service_id
      @version = version
      @connection = connection
    end

    # Finds an endpoint and calls it with the given options.
    # If there is a connection failure, new attempts are
    # made with new endpoints.
    #
    # Two failure modes are handled:
    # 1. There are no registered endpoints: NoEndpointError
    # 2. None of the registered endpoints respond: NoResponseError
    #
    # Zookeeper is only called when there are no longer any
    # responding endpoints in the list. Endpoints are queried
    # in a round-robin fashion.
    def call(opts = {})
      @endpoints ||= []
      @endpoints = @connection.get_endpoints(@service_id, @version) if @endpoints.empty?
      raise NoEndpointError if @endpoints.empty?
      resource_id = opts.delete(:id)

      begin
        endpoint = @endpoints.shift
        path = [endpoint, resource_id].compact.join('/')
        response = HTTParty.get(path, opts) rescue nil
        unless response.nil?
          @endpoints.push(endpoint)
          return response
        end
      end while @endpoints.any?

      raise NoResponseError
    end
  end

end
