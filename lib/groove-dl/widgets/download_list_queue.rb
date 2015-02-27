# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download bar section
    class DownloadListQueue < Events
      attr_accessor :search_list, :songs
      attr_accessor :failed, :success, :queue

      COLUMN_PATH,
      COLUMN_PGBAR_VALUE,
      COLUMN_PGBAR_TEXT = *(0..2).to_a

      def initialize(client, app, search_list)
        super(client, app)
        @songs = {}
        @search_list = search_list
        @downloader = GrooveDl::Downloader.new(@client)
        @downloader.type = 'gui'
      end

      def on_btn_clear_queue_clicked
        @app.get_object('download_queue_list_store').clear
      end

      def on_btn_add_to_queue_clicked
        selected = {}
        column_id = GrooveDl::Widgets::Search::COLUMN_ID
        column_checkbox = GrooveDl::Widgets::Search::COLUMN_CHECKBOX
        search_list_store = @app.get_object('search_list_store')
        search_list_store.each do |_model, _path, iter|
          next unless iter[column_checkbox]
          selected[iter[column_id]] = @search_list.data[iter[column_id]]
        end

        @store = @app.get_object('download_queue_list_store')
        create_model(selected)

        @queue = @songs.count
        @app.get_object('download_label_queue')
          .set_text(format('Queue (%d)', @queue))
      end

      def create_model(data)
        data.each do |id, element|
          if element.is_a?(Grooveshark::Song)
            iter = @store.append
            iter[COLUMN_PATH] =
              @downloader.build_path(@app.get_object('directory_chooser')
                                       .filename,
                                     element)
            iter[COLUMN_PGBAR_VALUE] = 0
            iter[COLUMN_PGBAR_TEXT] = nil
            @songs[element.id] = { iter: iter, song: element }
          else
            playlist = Grooveshark::Playlist.new(@client,
                                                 'playlist_id' => id)
            result = {}
            playlist.load_songs.each do |song|
              result[song.id] = song
            end

            create_model(result)
          end
        end

        return if @songs.empty?
      end
    end
  end
end
