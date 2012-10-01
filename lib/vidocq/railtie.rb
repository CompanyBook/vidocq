require 'rails'

module Vidocq
  class Railtie < ::Rails::Railtie
    initializer 'Rails logger' do
      Vidocq.logger = Rails.logger
    end
  end
end
