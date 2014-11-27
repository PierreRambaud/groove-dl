# -*- coding: utf-8 -*-
module GrooveDl
  # Bootstraper for the application
  class App < Gtk::Window
    def initialize
      super

      box = Gtk::Box.new(:vertical)
      search_bar = Widgets::Search.new(:vertical, 6)
      search_bar.load(self)
      list = Widgets::List.new(:vertical, 6)
      list.load(self)

      box.pack_start(search_bar, expand: false, fill: true, padding: 10)
      box.pack_start(list, expand: true, fill: true, padding: 10)

      add(box)

      init_default
    end

    def init_default
      signal_connect('destroy') do
        Gtk.main_quit
      end

      set_title('Grooveshark Downloader')
      set_default_size(800, 600)
      set_window_position(:center)
      show_all
    end
  end
end
