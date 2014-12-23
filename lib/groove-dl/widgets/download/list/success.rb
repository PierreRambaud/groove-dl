# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download section
    module Download
      # List page
      module List
        # Success tree
        class Success < Gtk::Box
          attr_reader :store, :data, :treeview

          COLUMN_PATH,
          COLUMN_SIZE = *(0..1).to_a
          RIGHT_CLICK = 3

          ##
          # Initialize widgets
          #
          # @param [Grooveshark::Client] client Grooveshark client
          # @param [Gtk::Window] window Gtk app
          #
          def load(_client, _window, menu)
            @data = {}
            sw = Gtk::ScrolledWindow.new
            sw.shadow_type = Gtk::ShadowType::ETCHED_IN
            sw.set_policy(Gtk::PolicyType::AUTOMATIC,
                          Gtk::PolicyType::AUTOMATIC)
            pack_start(sw, expand: true, fill: true, padding: 0)

            @store = Gtk::ListStore.new(String, String)
            @treeview = Gtk::TreeView.new(@store)
            @treeview.rules_hint = true

            @treeview.signal_connect('button_press_event') do |widget, event|
              if event.is_a?(Gdk::EventButton) && event.button == RIGHT_CLICK
                path, _model = widget.get_path_at_pos(event.x, event.y)
                widget.selection.select_path(path)
                menu.popup(nil, nil, event.button, event.time)
              end
            end

            sw.add(@treeview)

            add_columns
          end

          ##
          # Append row in the list store
          #
          # @param [Gtk::TreeIter] i Iterable element
          #
          def create_model(i)
            iter = @store.append
            path = i[COLUMN_PATH]
            iter[COLUMN_PATH] = path
            size = (File.size?(path).to_f / (1024 * 1024)).round(2)
            iter[COLUMN_SIZE] = "#{size} MB"
          end

          ##
          # Add columns on the treeview element
          #
          def add_columns
            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Path',
                                             renderer,
                                             'text' => COLUMN_PATH)
            column.fixed_width = 650
            @treeview.append_column(column)

            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Size',
                                             renderer,
                                             'text' => COLUMN_SIZE)
            column.fixed_width = 100
            @treeview.append_column(column)
          end
        end
      end
    end
  end
end
