# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Search section
    module Search
      # Search bar
      class Bar < Gtk::Box
        attr_reader :type, :query

        ##
        # Initialize widgets
        #
        # @param [Grooveshark::Client] client Grooveshark client
        # @param [Gtk::Window] window Gtk app
        #
        def load(client, window)
          search_box = Gtk::Box.new(:horizontal, 6)

          search_bar = Gtk::Entry.new
          search_bar.set_name('search_bar')
          search_bar.text = 'CruciAGoT'
          search_box.pack_start(search_bar,
                                expand: true,
                                fill: true,
                                padding: 10)

          search_type = Gtk::ComboBoxText.new
          search_type.set_name('search_type')
          search_type.append_text 'Playlists'
          search_type.append_text 'Songs'
          search_type.active = 0

          search_box.pack_start(search_type,
                                expand: false,
                                fill: true,
                                padding: 5)

          button = Gtk::Button.new(stock_id: Gtk::Stock::FIND)
          button.signal_connect('released') do
            @type = search_type.active_text
            @query = search_bar.text
            next if @type.empty? || @query.empty?
            search = client.request('getResultsFromSearch',
                                    type: @type,
                                    query: @query)
            results = search['result'].map do |data|
              next Grooveshark::Song.new data if type == 'Songs'
              data
            end if search.key?('result')

            window.find_by_name('search_list').create_model(results)
          end

          search_box.pack_start(button,
                                expand: false,
                                fill: false,
                                padding: 10)

          pack_start(search_box,
                     expand: false,
                     padding: 10)
        end
      end
    end
  end
end
