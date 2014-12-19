# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # Download book
    class DownloadBook < Gtk::Notebook
      def load(client, window)
        set_name('download_book')
        set_tab_pos(Gtk::PositionType::TOP)

        # Download list
        download_list = Widgets::DownloadList.new(:vertical, 6)
        download_list.set_name('download_list')
        download_list.load(client, window)

        download_list_label = Gtk::Label.new('Queue')
        download_list_label.set_name('download_list_label')
        append_page(download_list, download_list_label)

        # Success list
        download_success_list = Widgets::DownloadSuccessList.new(:vertical, 6)
        download_success_list.set_name('download_success_list')
        download_success_list.load(client, window)

        download_success_list_label = Gtk::Label.new('Downloaded')
        download_success_list_label.set_name('download_success_list_label')
        append_page(download_success_list, download_success_list_label)

        # Failed list
        download_failed_list = Widgets::DownloadFailedList.new(:vertical, 6)
        download_failed_list.set_name('download_failed_list')
        download_failed_list.load(client, window)

        download_list_label = Gtk::Label.new('Queue')
        download_success_list_label.set_name('download_list_label')

        append_page(download_failed_list, Gtk::Label.new('Failed'))
      end
    end
  end
end
