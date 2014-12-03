# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # Download list tree
    class DownloadList < Gtk::Box
      attr_reader :store
      attr_writer :downloader, :client

      COLUMN_PATH,
      COLUMN_PROGRESS = *(0..2).to_a

      def load(client, _window)
        @client = client
        @downloader = GrooveDl::Downloader.new(@client)
        sw = Gtk::ScrolledWindow.new
        sw.shadow_type = Gtk::ShadowType::ETCHED_IN
        sw.set_policy(Gtk::PolicyType::AUTOMATIC, :automatic)
        pack_start(sw, expand: true, fill: true, padding: 0)

        @store = Gtk::ListStore.new(String, Gtk::ProgressBar)
        create_model
        treeview = Gtk::TreeView.new(@store)
        treeview.rules_hint = true

        sw.add(treeview)

        add_columns(treeview)
      end

      def create_model(data = [])
        data.each do |element|
          if element.is_a?(Grooveshark::Song)
            iter = @store.append
            iter[COLUMN_PATH] = @downloader.build_path(Dir.tmpdir, element)
            iter[COLUMN_PROGRESS] = Gtk::ProgressBar.new
          else
            puts element.inspect
            playlist = @client.request('getPlaylistByID',
                                       playlistID: element['playlist_id'].to_i)
            return unless playlist.key?('songs')
            result = []
            playlist['songs'].each do |song|
              result << Grooveshark::Song.new(song)
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

        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('Progress',
                                         renderer,
                                         'text' => COLUMN_PROGRESS)
        column.set_sort_column_id(COLUMN_PROGRESS)
        column.fixed_width = 100
        treeview.append_column(column)
      end
    end
  end
end
