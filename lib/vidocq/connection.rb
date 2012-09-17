require 'httparty'
require 'json'

require 'vidocq/cache'

module Vidocq
  class Connection
    def initialize(*args, opts)
      @cache = Cache.new(*args, opts || {})
    end

    # Finds an endpoint and calls it with the given options.
    # If there is a connection failure, new attempts are
    # made with new endpoints.
    #
    # Two failure modes are handled:
    # 1. There are no registered endpoints: NoEndpointError
    # 2. None of the registered endpoints respond: NoResponseError
    def call(opts = {})
      resource_id = opts.delete(:id)

      endpoints = @cache.endpoints
      raise NoEndpointError if endpoints.empty?
        
      begin
        endpoint = endpoints.slice!(rand(endpoints.size))
        path = [endpoint, resource_id].compact.join('/')
        response = HTTParty.get(path, opts) rescue nil
        return response unless response.nil?
      end while endpoints.any?

      raise NoResponseError
    end
  end
end
