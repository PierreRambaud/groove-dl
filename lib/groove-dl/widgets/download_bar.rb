# -*- coding: utf-8 -*-
module GrooveDl
  # Application component
  module Widgets
    # Download bar
    class DownloadBar < Gtk::Box
      attr_reader :type, :query

      def load(_client, window)
        download_box = Gtk::Box.new(:horizontal, 6)

        add_button = Gtk::Button.new(label: 'Add to queue',
                                     stock_id: Gtk::Stock::SAVE)

        add_button.signal_connect('released') do
          l = window.find_by_name('download_list')
          l.store.clear
          l.create_model(window.find_by_name('search_list').selection)
        end

        download_box.pack_start(add_button,
                                expand: false,
                                fill: true,
                                padding: 5)

        directory_chooser = Gtk::FileChooserButton
                            .new('Select directory',
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
        concurrency_entry.width_chars = 5

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

        download_button = Gtk::Button.new(label: 'Download',
                                          stock_id: Gtk::Stock::SAVE)

        download_button.signal_connect('released') do
          download_button.sensitive = false
          window.find_by_name('download_list').download
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
