# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Search section
    class Events
      attr_reader :client, :app

      def initialize(client, app)
        @client = client
        @app = app

        app.connect_signals do |handler|
          method(handler) if respond_to?(handler)
        end
      end
    end
  end
end
