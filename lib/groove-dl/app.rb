# -*- coding: utf-8 -*-
module GrooveDl
  # Bootstraper for the application
  class App < Gtk::Window
    def initialize
      super

      client = Grooveshark::Client.new
      box = Gtk::Box.new(:vertical)

      search_bar = Widgets::SearchBar.new(:vertical, 6)
      search_bar.load(client, self)

      list = Widgets::SearchList.new(:vertical, 6)
      list.set_name('list')
      list.load(client, self)

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

    def find_by_name(element = self, name)
      return element if element.name == name
      element.children.each do |child|
        result = find_by_name(child, name)
        return result unless result.nil?
      end if element.respond_to?(:children)

      nil
    end
  end
end
