require 'httparty'
require 'cgi'
require 'vidocq/cache'
require 'active_support/core_ext/object'

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
      with_endpoint do |endpoint|
        resource_id = opts.delete(:id)
        path = [endpoint, resource_id].compact.join('/')
        url = "#{path}?#{opts.to_param}"
        return HTTParty.get(url, :timeout => 4)
      end
    end

    alias_method :get, :call

    # Finds an arbitrary endpoint and does a POST to it
    # with the given json payload. If there is a connection
    # failure, new attempts are made with new endpoints.
    #
    # Be wary to use this for idempotent operations, as
    # it is possible that the post is performed twice.
    def post(json)
      with_endpoint do |endpoint|
        url = endpoint + '/'
        return HTTParty.post(url, :body => json, :timeout => 4, :headers => {'Content-Type' => 'application/json' })
      end
    end

    # Finds an arbitrary endpoint and PUTs the given data
    # as JSON, using the path with the given ID.
    def put(id, json)
      with_endpoint do |endpoint|
        url = "#{endpoint}/#{id}/"
        return HTTParty.put(url, :body => json, :timeout => 4, :headers => {'Content-Type' => 'application/json' })
      end
    end

    # Finds an arbitrary endpoint and issues a DELETE for
    # the path with the given ID.
    def delete(id)
      with_endpoint do |endpoint|
        url = "#{endpoint}/#{id}/"
        return HTTParty.delete(url, :timeout => 4)
      end
    end

    # Returns all active endpoints for this service.
    def get_endpoints
      endpoints = @cache.endpoints || []
      endpoints.empty? ? @fallbacks : endpoints
    end

    private

    def with_endpoint(&blk)
      endpoints = get_endpoints
      raise NoEndpointError if endpoints.empty?
      Vidocq.logger.info "Vidocq endpoints: #{endpoints}"
        
      begin
        endpoint = endpoints.slice!(rand(endpoints.size))
        begin
          return yield(endpoint) if block_given?
        rescue Exception => e
          Vidocq.logger.warn "Error accessing '#{endpoint}': #{e}."
        end
      end while endpoints.any?

      raise NoResponseError
    end
  end
end
