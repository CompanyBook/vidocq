require 'zk'
require 'json'
require 'vidocq/connection'

module Vidocq

  class NoEndpointError < StandardError; end
  class NoResponseError < StandardError; end

  # Connection factory
  def self.new(sid, version, opts = {})
    Connection.new(sid, version, opts || {})
  end

  def self.logger=(new_logger)
    @logger = new_logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
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
  def self.services(connect_string = nikjl)
    base_path = "/companybook/services"
    ZK.open(connect_string || 'localhost:2181') do |zk|
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
