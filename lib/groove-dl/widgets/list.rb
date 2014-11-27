# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # List tree
    class List < Gtk::Box
      COLUMN_ID,
      COLUMN_NAME,
      COLUMN_AUTHOR,
      COLUMN_SONG = *(0..4).to_a

      def load(_client, _window)
        sw = Gtk::ScrolledWindow.new(nil, nil)
        sw.shadow_type = Gtk::ShadowType::ETCHED_IN
        sw.set_policy(Gtk::PolicyType::NEVER, :automatic)
        pack_start(sw, expand: true, fill: true, padding: 0)

        # create tree view
        @store = Gtk::ListStore.new(Integer, String, String, String)
        create_model
        treeview = Gtk::TreeView.new(@store)
        treeview.rules_hint = true
        treeview.search_column = COLUMN_SONG

        sw.add(treeview)

        # add columns to the tree view
        add_columns(treeview)
      end

      def create_model(data = [])
        # create list store
        @store.clear
        # add data to the list store
        data.each do |element|
          iter = @store.append
          if element.is_a?(Grooveshark::Song)
            iter[0] = element.id.to_i
            iter[1] = element.name
            iter[2] = element.artist
            iter[3] = element.album
          else
            iter[0] = element['playlist_id'].to_i
            iter[1] = element['name']
            iter[2] = element['f_name']
            iter[3] = element['num_songs']
          end
        end
      end

      def add_columns(treeview)
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Id',
                                         renderer,
                                         'text' => COLUMN_ID)
        column.set_sort_column_id(COLUMN_ID)
        column.sizing = Gtk::TreeViewColumn::Sizing::FIXED
        column.fixed_width = 70
        treeview.append_column(column)

        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Name',
                                         renderer,
                                         'text' => COLUMN_NAME)
        column.set_sort_column_id(COLUMN_NAME)
        column.fixed_width = 400
        treeview.append_column(column)

        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Author',
                                         renderer,
                                         'text' => COLUMN_AUTHOR)
        column.set_sort_column_id(COLUMN_AUTHOR)
        column.fixed_width = 200
        treeview.append_column(column)

        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Number of songs',
                                         renderer,
                                         'text' => COLUMN_SONG)
        column.set_sort_column_id(COLUMN_SONG)
        column.fixed_width = 50
        treeview.append_column(column)
      end
    end
  end
end
