require 'httparty'
require 'json'
require 'zk'

module Vidocq
  class NoEndpointError < StandardError; end
  class NoResponseError < StandardError; end

  def self.new(connect_string = nil)
    Connection.new(connect_string)
  end

  class Connection
    def initialize(connect_string = nil)
      @cs = connect_string || 'localhost:2181'
    end

    # Looks up all currently running instances of the
    # specified service. Picks an arbitrary one and
    # returns its instance. If the instance does not
    # respond, call this method again until you get one
    # that does.
    def get_endpoint(service_id, version)
      raise 'Missing service id' if service_id.nil? or service_id.empty?
      raise 'Missing service version' if version.nil? or version.empty?

      base_path = "/companybook/services/#{service_id}/#{version}"
      ZK.open(@cs) do |zk|
        children = get_children(zk, service_id, version)
        return if children.empty?
        path = children.sample
        data = JSON.parse(zk.get(base_path + '/' + path).first)
        data['endpoint']
      end
    end

    # Finds an endpoint and calls it with the given options.
    # If there is a connection failure, new attempts are
    # made with new endpoints.
    #
    # Two failure modes are handled:
    # 1. There are no registered endpoints: NoEndpointError
    # 2. None of the registered endpoints respond: NoResponseError
    def call(opts = {})
      service_id = opts.delete(:service_id) { raise 'Missing service id' }
      version = opts.delete(:version) { raise 'Missing version' }
      base_path = "/companybook/services/#{service_id}/#{version}"
      resource_id = opts.delete(:id)

      ZK.open(@cs) do |zk|
        children = get_children(zk, service_id, version)
        raise NoEndpointError if children.empty?
        
        begin
          child = children.slice!(rand(children.size))
          data = JSON.parse(zk.get(base_path + '/' + child).first)
          endpoint = data['endpoint']
          path = [endpoint, resource_id].compact.join('/')
          response = HTTParty.get(path, opts) rescue nil
          return response unless response.nil?
        end while children.any?

        raise NoResponseError
      end
    end

    # Lists all the services, versions and instances
    # in an  hierarcical format like the following:
    #
    # [
    #   {:name => 'fooservice', :versions =>
    #     [
    #       {:number => '0.1', :instances =>
    #         [
    #           {:endpoint => 'http://198.0.0.1:8900/foo'}, ...
    #         ]
    #       }, ...
    #     ]
    #   }, ...
    # ]
    def services
      base_path = "/companybook/services"

      ZK.open(@cs) do |zk|
        return [] unless zk.exists?(base_path)
        return zk.children(base_path).collect do |service|
          service_path = base_path + '/' + service
          versions = zk.children(service_path).collect do |version|
            version_path = service_path + '/' + version
            instances = zk.children(version_path).collect do |instance|
              JSON.parse(zk.get(version_path + '/' + instance).first)
            end
            {:number => version, :instances => instances}
          end
          {:name => service, :versions => versions}
        end
      end
    end

    private

    def get_children(zk, id, version)
      base_path = "/companybook/services/#{id}/#{version}"
      return [] unless zk.exists?(base_path)
      zk.children(base_path)
    end
  end
end
