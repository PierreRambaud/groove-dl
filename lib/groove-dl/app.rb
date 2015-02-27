# -*- coding: utf-8 -*-
module GrooveDl
  # Bootstraper for the application
  class App < Gtk::Builder
    attr_accessor :signals_list

    def initialize(path)
      super()

      Gtk::Settings.default.gtk_button_images = true
      add_from_file(path)

      @signals_list = {}
      @main_window = get_object('main_window')
      @main_window.set_window_position(Gtk::Window::Position::CENTER)
      @main_window.signal_connect('destroy') { Gtk.main_quit }
      @main_window.show_all

      client = Grooveshark::Client.new
      search_list = Widgets::Search.new(client, self)
      Widgets::DownloadBar.new(client, self)
      Widgets::DownloadListQueue.new(client, self, search_list)

      connect_signals do |handler|
        @signals_list[handler] if @signals_list.key?(handler)
      end
    end
  end
end
