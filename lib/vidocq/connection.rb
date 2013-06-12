require 'httparty'
require 'cgi'
require 'vidocq/cache'

module Vidocq
  class Connection
    def initialize(sid, version, opts = {})
      @fallbacks = opts.delete(:fallbacks) || []
      @cache = Cache.new(sid, version, opts)
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
      endpoints = get_endpoints
      raise NoEndpointError if endpoints.empty?
      Vidocq.logger.info "Vidocq endpoints: #{endpoints}"
        
      begin
        endpoint = endpoints.slice!(rand(endpoints.size))
        path = [endpoint, resource_id].compact.join('/')
        url = "#{path}?#{build_querystring(opts)}"
        begin
          return HTTParty.get(url)
        rescue Exception => e
          Vidocq.logger.warn "Error requesting '#{url}': #{e}."
        end
      end while endpoints.any?

      Vidocq.logger.warn "Vidocq: Unable to reach any of the endpoints"

      raise NoResponseError
    end

    def get_endpoints
      endpoints = @cache.endpoints || []
      endpoints.empty? ? @fallbacks : endpoints
    end

    private

    def build_querystring(opts = {})
      opts.to_param
    end
  end
end
