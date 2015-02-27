# -*- coding: utf-8 -*-
module GrooveDl
  # Bootstraper for the application
  class App < Gtk::Builder
    def initialize(path)
      super()

      Gtk::Settings.default.gtk_button_images = true
      add_from_file(path)

      @main_window = get_object('main_window')
      @main_window.set_window_position(Gtk::Window::Position::CENTER)
      @main_window.signal_connect('destroy') { Gtk.main_quit }
      @main_window.show_all

      client = Grooveshark::Client.new
      Widgets::Search.new(client, self)
    end
  end
end
