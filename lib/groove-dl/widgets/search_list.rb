# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # Search list tree
    class SearchList < Gtk::Box
      attr_reader :data
      attr_reader :store
      attr_reader :selection

      COLUMN_FIXED,
      COLUMN_ID,
      COLUMN_NAME,
      COLUMN_AUTHOR,
      COLUMN_SONG = *(0..5).to_a

      def load(_client, _window)
        @selection = {}
        sw = Gtk::ScrolledWindow.new
        sw.shadow_type = Gtk::ShadowType::ETCHED_IN
        sw.set_policy(Gtk::PolicyType::AUTOMATIC, :automatic)
        pack_start(sw, expand: true, fill: true, padding: 0)

        @store = Gtk::ListStore.new(TrueClass, Integer, String, String, String)
        create_model
        treeview = Gtk::TreeView.new(@store)
        treeview.rules_hint = true
        treeview.search_column = COLUMN_SONG

        sw.add(treeview)

        add_columns(treeview)
      end

      def create_model(data = [])
        @store.clear
        @data = {}
        data.each do |element|
          iter = @store.append
          iter[COLUMN_FIXED] = false
          if element.is_a?(Grooveshark::Song)
            @data[element.id.to_i] = element
            iter[COLUMN_ID] = element.id.to_i
            iter[COLUMN_NAME] = element.name
            iter[COLUMN_AUTHOR] = element.artist
            iter[COLUMN_SONG] = element.album
          else
            @data[element['playlist_id'].to_i] = element
            iter[COLUMN_ID] = element['playlist_id'].to_i
            iter[COLUMN_NAME] = element['name']
            iter[COLUMN_AUTHOR] = element['f_name']
            iter[COLUMN_SONG] = element['num_songs']
          end
        end
      end

      def add_columns(treeview)
        renderer = Gtk::CellRendererToggle.new
        renderer.signal_connect('toggled') do |_cell, path|
          fixed_toggled(treeview.model, path)
        end

        column = Gtk::TreeViewColumn.new('X',
                                         renderer,
                                         'active' => COLUMN_FIXED)
        column.sizing = Gtk::TreeViewColumn::Sizing::FIXED
        column.fixed_width = 30
        treeview.append_column(column)

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
        column = Gtk::TreeViewColumn.new('Other data',
                                         renderer,
                                         'text' => COLUMN_SONG)
        column.set_sort_column_id(COLUMN_SONG)
        column.fixed_width = 100
        treeview.append_column(column)
      end

      def fixed_toggled(model, path_str)
        path = Gtk::TreePath.new(path_str)
        iter = model.get_iter(path)
        fixed = iter[COLUMN_FIXED]
        fixed ^= 1
        iter[COLUMN_FIXED] = fixed
        @selection[iter[COLUMN_ID]] = @data[iter[COLUMN_ID]] if fixed
        @selection.delete(iter[COLUMN_ID]) unless fixed
      end
    end
  end
end
