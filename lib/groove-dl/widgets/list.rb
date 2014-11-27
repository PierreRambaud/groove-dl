# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # List tree
    class List < Gtk::Box
      COLUMN_FIXED,
      COLUMN_NUMBER,
      COLUMN_SEVERITY,
      COLUMN_DESCRIPTION = *(0..4).to_a

      def load(_window)
        sw = Gtk::ScrolledWindow.new(nil, nil)
        sw.shadow_type = Gtk::ShadowType::ETCHED_IN
        sw.set_policy(Gtk::PolicyType::NEVER, :automatic)
        pack_start(sw, expand: true, fill: true, padding: 0)

        # create tree view
        model = create_model
        treeview = Gtk::TreeView.new(model)
        treeview.rules_hint = true
        treeview.search_column = COLUMN_DESCRIPTION

        sw.add(treeview)

        # add columns to the tree view
        add_columns(treeview)
      end

      def create_model(data = [])
        # create list store
        store = Gtk::ListStore.new(TrueClass, Integer, String, String)

        # add data to the list store
        data.each do |bug|
          iter = store.append
          bug.each_with_index do |value, index|
            iter[index] = value
          end
        end
        store
      end

      def add_columns(treeview)
        # column for fixed toggles
        renderer = Gtk::CellRendererToggle.new
        renderer.signal_connect('toggled') do |_cell, path|
          fixed_toggled(treeview.model, path)
        end

        column = Gtk::TreeViewColumn.new('Fixed?',
                                         renderer,
                                         'active' => COLUMN_FIXED)

        # set this column to a fixed sizing (of 50 pixels)
        column.sizing = Gtk::TreeViewColumn::Sizing::FIXED
        column.fixed_width = 50
        treeview.append_column(column)

        # column for bug numbers
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Bug number',
                                         renderer,
                                         'text' => COLUMN_NUMBER)
        column.set_sort_column_id(COLUMN_NUMBER)
        treeview.append_column(column)

        # column for severities
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Severity',
                                         renderer,
                                         'text' => COLUMN_SEVERITY)
        column.set_sort_column_id(COLUMN_SEVERITY)
        treeview.append_column(column)

        # column for description
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Description',
                                         renderer,
                                         'text' => COLUMN_DESCRIPTION)
        column.set_sort_column_id(COLUMN_DESCRIPTION)
        treeview.append_column(column)
      end

      def fixed_toggled(model, path_str)
        path = Gtk::TreePath.new(path_str)

        # get toggled iter
        iter = model.get_iter(path)
        fixed = iter[COLUMN_FIXED]

        # do something with the value
        fixed ^= 1

        # set new value
        iter[COLUMN_FIXED] = fixed
      end
    end
  end
end
