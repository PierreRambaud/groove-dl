# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download section
    module Menu
      # Success menu
      class Success < Gtk::Menu
        ##
        # Initialize widgets
        #
        # @param [Grooveshark::Client] client Grooveshark client
        # @param [Gtk::Window] window Gtk app
        #
        def load(_client, window)
          item = Gtk::ImageMenuItem.new(stock_id: Gtk::Stock::OPEN)
          item.signal_connect('activate') do
            treeview = window.find_by_name('download_success_list').treeview
            path = Gtk::TreePath.new(treeview.selection.selected)
            iter = treeview.model.get_iter(path)
          end

          append(item)

          show_all
        end
      end
    end
  end
end
