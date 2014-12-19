# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download section
    module Download
      # Download book
      class Book < Gtk::Notebook
        attr_reader :window

        QUEUE = 'Queue (%d)'
        SUCCESS = 'Success (%d)'
        FAILED = 'Failed (%d)'

        def load(client, window)
          @window = window
          set_name('download_book')
          set_tab_pos(Gtk::PositionType::TOP)

          # Download list
          download_list = Widgets::Download::List::Queue.new(:vertical, 6)
          download_list.set_name('download_list')
          download_list.load(client, window)

          @download_label = Gtk::Label.new(QUEUE % 0)
          @download_label.set_name('download_label')
          append_page(download_list, @download_label)

          # Success list
          download_success_list =
            Widgets::Download::List::Success.new(:vertical, 6)
          download_success_list.set_name('download_success_list')
          download_success_list.load(client, window)

          @download_success_label = Gtk::Label.new(SUCCESS % 0)
          @download_success_label.set_name('download_success_label')
          append_page(download_success_list, @download_success_label)

          # Failed list
          download_failed_list =
            Widgets::Download::List::Failed.new(:vertical, 6)
          download_failed_list.set_name('download_failed_list')
          download_failed_list.load(client, window)

          @download_failed_label = Gtk::Label.new(FAILED % 0)
          @download_failed_label.set_name('download_failed_label')
          append_page(download_failed_list, @download_failed_label)
        end

        def set_label(type, nb)
          element = @download_label if type == 'QUEUE'
          element = @download_success_label if type == 'SUCCESS'
          element = @download_failed_label if type == 'FAILED'

          return if element.nil?
          element.set_text(Book.const_get(type.upcase) % nb)
        end
      end
    end
  end
end
