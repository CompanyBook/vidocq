require 'json'
require 'zk'

module Vidocq
  VERSION = "0.0.1"

  def self.new(connect_string = nil)
    Connection.new(connect_string)
  end

  class Connection
    def initialize(connect_string = nil)
      @cs = connect_string || 'localhost:2181'
    end

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
  end
end
