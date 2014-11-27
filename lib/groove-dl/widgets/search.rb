# -*- coding: utf-8 -*-
module GrooveDl
  # Application component
  module Widgets
    # Search bar
    class Search < Gtk::Box
      def load(_window)
        search_box = Gtk::Box.new(:horizontal, 6)
        label = Gtk::Label.new('Search')
        search_box.pack_start(label,
                              expand: false,
                              fill: true,
                              padding: 10)
        search_bar = Gtk::Entry.new
        search_bar.set_name('search_bar')
        search_box.pack_start(search_bar,
                              expand: true,
                              fill: true,
                              padding: 10)

        button = Gtk::Button.new(label: 'Search', stock_id: Gtk::Stock::FIND)
        button.signal_connect('released') do
          puts 'cliked'
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
