require 'json'
require 'zk'

module Vidocq
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
      base_path = "/companybook/services/#{service_id}/#{version}"
      ZK.open(@cs) do |zk|
        return unless zk.exists?(base_path)
        path = zk.children(base_path).sample
        return unless path
        data = JSON.parse(zk.get(base_path + '/' + path).first)
        data['endpoint']
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
  end
end
