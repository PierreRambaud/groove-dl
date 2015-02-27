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

        self.methods.each do |name|
          unless name.match(/^on_/)
            next
          end

          @app.signals_list[name.to_s] = method(name)
        end
      end
    end
  end
end
