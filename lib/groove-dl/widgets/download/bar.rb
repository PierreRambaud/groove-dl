# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download section
    module Download
      # Download bar
      class Bar < Gtk::Box
        attr_reader :type, :query

        ##
        # Initialize widgets
        #
        # @param [Grooveshark::Client] client Grooveshark client
        # @param [Gtk::Window] window Gtk app
        #
        def load(_client, window)
          set_name('download_bar')

          download_box = Gtk::Box.new(:horizontal, 6)

          add_button = Gtk::Button.new(stock_id: Gtk::Stock::ADD)

          add_button.signal_connect('released') do
            l = window.find_by_name('download_list')
            l.store.clear
            search_list = window.find_by_name('search_list')
            selected = {}
            column_id = GrooveDl::Widgets::Search::List::COLUMN_ID
            column_checkbox = GrooveDl::Widgets::Search::List::COLUMN_CHECKBOX
            search_list.store.each do |_model, _path, iter|
              next unless iter[column_checkbox]
              selected[iter[column_id]] = search_list.data[iter[column_id]]
            end

            l.create_model(selected)
          end

          download_box.pack_start(add_button,
                                  expand: false,
                                  fill: true,
                                  padding: 5)

          directory_chooser =
            Gtk::FileChooserButton.new('Select directory',
                                       Gtk::FileChooser::Action::SELECT_FOLDER)
          directory_chooser.filename = Dir.tmpdir
          directory_chooser.set_name('directory_chooser')
          download_box.pack_start(directory_chooser,
                                  expand: true,
                                  fill: true,
                                  padding: 5)

          concurrency_entry = Gtk::Entry.new
          concurrency_entry.set_name('concurrency_entry')
          concurrency_entry.text = '5'

          concurrency_label = Gtk::Label.new('Concurrency', true)
          concurrency_label.mnemonic_widget = concurrency_entry

          download_box.pack_start(concurrency_label,
                                  expand: false,
                                  fill: false,
                                  padding: 5)
          download_box.pack_start(concurrency_entry,
                                  expand: false,
                                  fill: false,
                                  padding: 5)

          concurrency_entry.signal_connect('changed') do
            value = concurrency_entry.text.to_i
            concurrency_entry.text = value.to_s unless value == 0
          end

          download_button = Gtk::Button.new(stock_id: Gtk::Stock::SAVE)

          download_button.signal_connect('released') do
            download_list = window.find_by_name('download_list')
            next if download_list.queue.zero?
            download_button.sensitive = false
            download_list.download
          end

          download_box.pack_start(download_button,
                                  expand: false,
                                  fill: true,
                                  padding: 5)

          pack_start(download_box,
                     expand: false,
                     padding: 10)
        end
      end
    end
  end
end
