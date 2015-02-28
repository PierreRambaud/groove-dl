# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Search section
    class Events
      attr_reader :client, :app

      ##
      # Initialize events for signals
      #
      def initialize(client, app)
        @client = client
        @app = app

        methods.each do |name|
          next unless name.match(/^on_/)
          @app.signals_list[name.to_s] = method(name)
        end
      end
    end
  end
end
