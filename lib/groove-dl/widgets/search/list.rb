# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Search section
    module Search
      # Search list tree
      class List < Gtk::Box
        attr_reader :data
        attr_reader :store

        COLUMN_CHECKBOX,
        COLUMN_ID,
        COLUMN_NAME,
        COLUMN_AUTHOR,
        COLUMN_SONG = *(0..4).to_a

        ##
        # Initialize widgets
        #
        # @param [Grooveshark::Client] client Grooveshark client
        # @param [Gtk::Window] window Gtk app
        #
        def load(_client, _window)
          set_name('search_list')

          sw = Gtk::ScrolledWindow.new
          sw.shadow_type = Gtk::ShadowType::ETCHED_IN
          sw.set_policy(Gtk::PolicyType::AUTOMATIC, Gtk::PolicyType::AUTOMATIC)
          pack_start(sw, expand: true, fill: true, padding: 0)

          @store = Gtk::ListStore.new(TrueClass,
                                      Integer,
                                      String,
                                      String,
                                      String)
          create_model
          treeview = Gtk::TreeView.new(@store)
          treeview.rules_hint = true
          treeview.search_column = COLUMN_SONG

          sw.add(treeview)

          add_columns(treeview)
        end

        ##
        # Create line in the list store
        #
        # @param [Array] data Data stored
        #
        def create_model(data = [])
          @store.clear
          @data = {}
          data.each do |element|
            iter = @store.append
            iter[COLUMN_CHECKBOX] = false
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

        ##
        # Add columns on the treeview element
        #
        # @param [Gtk::Treeview] treeview Treeview
        #
        def add_columns(treeview)
          renderer = Gtk::CellRendererToggle.new
          renderer.signal_connect('toggled') do |_cell, path|
            fixed_toggled(treeview.model, path)
          end

          column = Gtk::TreeViewColumn.new('X',
                                           renderer,
                                           'active' => COLUMN_CHECKBOX)
          column.sizing = Gtk::TreeViewColumn::Sizing::FIXED
          column.fixed_width = 30
          column.set_clickable(true)
          column.signal_connect('clicked') do
            @store.each do |_model, _path, iter|
              fixed = iter[COLUMN_CHECKBOX]
              fixed ^= 1
              iter[COLUMN_CHECKBOX] = fixed
            end
          end

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

        ##
        # Fixed toggle button
        #
        # @param [Gtk::ListStore] model List store
        # @param [String] path_str Path to row
        #
        def fixed_toggled(model, path_str)
          path = Gtk::TreePath.new(path_str)
          iter = model.get_iter(path)
          fixed = iter[COLUMN_CHECKBOX]
          fixed ^= 1
          iter[COLUMN_CHECKBOX] = fixed
        end
      end
    end
  end
end
