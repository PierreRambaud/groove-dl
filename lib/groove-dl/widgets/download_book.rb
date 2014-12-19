# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # Download book
    class DownloadBook < Gtk::Notebook
      def load(client, window)
        set_tab_pos(Gtk::PositionType::TOP)

        download_list = Widgets::DownloadList.new(:vertical, 6)
        download_list.set_name('download_list')
        download_list.load(client, window)

        append_page(download_list, Gtk::Label.new('Queue'))

        downloaded_list = Widgets::DownloadSuccessList.new(:vertical, 6)
        downloaded_list.set_name('download_success_list')
        downloaded_list.load(client, window)

        append_page(downloaded_list, Gtk::Label.new('Downloaded'))

        download_failed_list = Widgets::DownloadFailedList.new(:vertical, 6)
        download_failed_list.set_name('download_failed_list')
        download_failed_list.load(client, window)

        append_page(download_failed_list, Gtk::Label.new('Failed'))
      end
    end
  end
end
