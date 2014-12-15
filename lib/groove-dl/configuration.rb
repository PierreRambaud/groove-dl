# -*- coding: utf-8 -*-
# Groove Dl module
module GrooveDl
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Configuration class
  class Configuration
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
