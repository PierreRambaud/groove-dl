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
          attr_reader :store, :data

          COLUMN_PATH,
          COLUMN_SIZE = *(0..1).to_a

          ##
          # Initialize widgets
          #
          # @param [Grooveshark::Client] client Grooveshark client
          # @param [Gtk::Window] window Gtk app
          #
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
          # @param [Gtk::Treeview] treeview Treeview
          #
          def add_columns(treeview)
            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Path',
                                             renderer,
                                             'text' => COLUMN_PATH)
            column.fixed_width = 650
            treeview.append_column(column)

            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new('Size',
                                             renderer,
                                             'text' => COLUMN_SIZE)
            column.fixed_width = 100
            treeview.append_column(column)
          end
        end
      end
    end
  end
end
