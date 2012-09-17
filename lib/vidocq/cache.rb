require 'zk'

module Vidocq
  class Cache
    def initialize(sid, version, opts = {})
      @ttl = opts.fetch(:ttl, 0)
      @cs = opts.fetch(:zk, 'localhost:2181')
      @parent = "/companybook/services/#{sid}/#{version}"
      @endpoints = []
    end

    def endpoints
      outdated? ? expire! : @endpoints
    end

    private

    def get_children(zk, path)
      zk.children(path) rescue []
    end

    def expire!
      @last_request = Time.now

      ZK.open(@cs) do |zk|
        @endpoints = zk.children(@parent).collect do |child|
          JSON.parse(zk.get(@parent + '/' + child).first)['endpoint']
        end
      end
    end

    def outdated?
      @endpoints.empty? or Time.now > (@last_request + @ttl)
    end
  end
end
