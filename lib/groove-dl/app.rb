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

      search_list = Widgets::SearchList.new(:vertical, 6)
      search_list.set_name('search_list')
      search_list.load(client, self)

      download_button = Gtk::Button.new(label: 'Download',
                                        stock_id: Gtk::Stock::SAVE)

      download_list = Widgets::DownloadList.new(:vertical, 6)
      download_list.set_name('download_list')
      download_list.load(client, self)

      download_button.signal_connect('released') do
        download_list.store.clear
        download_list.create_model(search_list.selection)
      end

      box.pack_start(search_bar, expand: false, fill: true, padding: 10)
      box.pack_start(search_list, expand: true, fill: true, padding: 5)
      box.pack_start(download_button, expand: false, fill: false, padding: 5)
      box.pack_start(download_list, expand: true, fill: true, padding: 5)

      add(box)

      init_default
    end

    def init_default
      signal_connect('destroy') do
        Gtk.main_quit
      end

      set_title('Grooveshark Downloader')
      set_default_size(1024, 768)
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
