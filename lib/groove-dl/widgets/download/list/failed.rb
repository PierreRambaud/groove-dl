# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download section
    module Download
      # List page
      module List
        # Failed tree
        class Failed < Gtk::Box
          attr_reader :store, :data

          COLUMN_PATH,
          COLUMN_REASON = *(0..2).to_a

          def load(_client, _window)
            @data = {}
            sw = Gtk::ScrolledWindow.new
            sw.shadow_type = Gtk::ShadowType::ETCHED_IN
            sw.set_policy(Gtk::PolicyType::AUTOMATIC,
                          Gtk::PolicyType::AUTOMATIC)
            pack_start(sw, expand: true, fill: true, padding: 0)

            @store = Gtk::ListStore.new(String, String)
            treeview = Gtk::TreeView.new(@store)
            treeview.rules_hint = true

            sw.add(treeview)

            add_columns(treeview)
          end

          def create_model(i, reason)
            iter = @store.append
            path = i[COLUMN_PATH]
            iter[COLUMN_PATH] = path
            iter[COLUMN_REASON] = reason
          end

          def add_columns(treeview)
            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Path',
                                             renderer,
                                             'text' => COLUMN_PATH)
            column.fixed_width = 650
            treeview.append_column(column)

            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Reason',
                                             renderer,
                                             'text' => COLUMN_REASON)
            column.fixed_width = 100
            treeview.append_column(column)
          end
        end
      end
    end
  end
end
