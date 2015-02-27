# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Download bar section
    class DownloadBar < Events
      def initialize(client, app)
        super(client, app)
        app.get_object('directory_chooser').filename = Dir.tmpdir
      end

      def on_btn_add_to_queue_clicked
        selected = {}
        column_id = GrooveDl::Widgets::Search::List::COLUMN_ID
        column_checkbox = GrooveDl::Widgets::Search::List::COLUMN_CHECKBOX
        search_list = @app.get_object('search_list')
        search_list.store.each do |_model, _path, iter|
          next unless iter[column_checkbox]
          selected[iter[column_id]] = search_list.data[iter[column_id]]
        end

        @store = @app.get_object('download_queue_list_store')
        @store.clear
        selected.each do |id, element|
          if element.is_a?(Grooveshark::Song)
            iter = @store.append
            iter[COLUMN_PATH] =
              @downloader.build_path(@window
                                       .find_by_name('directory_chooser')
                                       .filename,
                                     element)
            iter[COLUMN_PGBAR_VALUE] = 0
            iter[COLUMN_PGBAR_TEXT] = nil
            @data[element.id] = { iter: iter, song: element }
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

        return if @data.empty?
        @queue = @data.count
        @window.find_by_name('download_book').set_label('QUEUE', @queue)
      end
    end
  end
end
