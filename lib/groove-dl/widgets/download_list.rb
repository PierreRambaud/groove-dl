# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # Download list tree
    class DownloadList < Gtk::Box
      attr_reader :store, :data
      attr_writer :downloader, :client

      COLUMN_PATH,
      COLUMN_PROGRESS = *(0..2).to_a

      def load(client, _window)
        @client = client
        @data = {}
        @downloader = GrooveDl::Downloader.new(@client)
        sw = Gtk::ScrolledWindow.new
        sw.shadow_type = Gtk::ShadowType::ETCHED_IN
        sw.set_policy(Gtk::PolicyType::AUTOMATIC, :automatic)
        pack_start(sw, expand: true, fill: true, padding: 0)

        @store = Gtk::ListStore.new(String, Integer)
        create_model
        treeview = Gtk::TreeView.new(@store)
        treeview.rules_hint = true

        sw.add(treeview)

        add_columns(treeview)
      end

      def create_model(data = {})
        data.each do |id, element|
          if element.is_a?(Grooveshark::Song)
            iter = @store.append
            iter[COLUMN_PATH] = @downloader.build_path(Dir.tmpdir, element)
            iter[COLUMN_PROGRESS] = 0
            @data[element.id] = iter
          else
            playlist = @client.request('getPlaylistByID',
                                       playlistID: id)
            return unless playlist.key?('songs')
            result = {}
            playlist['songs'].each do |s|
              song = Grooveshark::Song.new(s)
              result[song.id] = song
            end
            create_model(result)
          end
        end
      end

      def add_columns(treeview)
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Path',
                                         renderer,
                                         'text' => COLUMN_PATH)
        column.set_sort_column_id(COLUMN_PATH)
        column.fixed_width = 650
        treeview.append_column(column)

        renderer = Gtk::CellRendererProgress.new
        column = Gtk::TreeViewColumn.new('Progress',
                                         renderer,
                                         value: 1,
                                         text: COLUMN_PROGRESS)
        column.set_sort_column_id(COLUMN_PROGRESS)
        column.fixed_width = 100
        treeview.append_column(column)
      end
    end
  end
end
