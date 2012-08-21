require "vidocq/version"
require "vidocq/connection"

module Vidocq
  def self.new(connect_string = nil)
    Connection.new(connect_string)
  end
end
