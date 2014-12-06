# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets modules
  module Widgets
    # Download list tree
    class DownloadList < Gtk::Box
      attr_reader :store, :data
      attr_writer :downloader, :client

      COLUMN_PATH,
      COLUMN_PGBAR_VALUE,
      COLUMN_PGBAR_TEXT = *(0..2).to_a

      def load(client, _window)
        @client = client
        @data = {}
        @downloader = GrooveDl::Downloader.new(@client)
        @downloader.type = 'gui'
        sw = Gtk::ScrolledWindow.new
        sw.shadow_type = Gtk::ShadowType::ETCHED_IN
        sw.set_policy(Gtk::PolicyType::AUTOMATIC, Gtk::PolicyType::AUTOMATIC)
        pack_start(sw, expand: true, fill: true, padding: 0)

        @store = Gtk::ListStore.new(String, Integer, String)
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
            iter[COLUMN_PGBAR_VALUE] = 0
            iter[COLUMN_PGBAR_TEXT] = nil
            @data[element.id] = { iter: iter, song: element }
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
        column.fixed_width = 650
        treeview.append_column(column)

        renderer = Gtk::CellRendererProgress.new
        column = Gtk::TreeViewColumn.new('Progress',
                                         renderer,
                                         value: COLUMN_PGBAR_VALUE,
                                         text: COLUMN_PGBAR_TEXT)
        column.fixed_width = 100
        treeview.append_column(column)
      end

      def download
        Thread.new do
          @data.each do |_id, s|
            @downloader.download(s[:song], s[:iter])
          end
        end
      end
    end
  end
end
