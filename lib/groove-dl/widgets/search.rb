# -*- coding: utf-8 -*-
module GrooveDl
  # Widgets components
  module Widgets
    # Search section
    class Search < Events
      attr_accessor :data, :store

      TYPE_PLAYLISTS,
      TYPE_SONGS,
      TYPE_PLAYLIST_ID = *(0..2).to_a

      COLUMN_CHECKBOX,
      COLUMN_ID,
      COLUMN_NAME,
      COLUMN_AUTHOR,
      COLUMN_SONG = *(0..4).to_a

      def on_search_entry_activate
        @app.get_object('search_button').signal_emit('clicked')
      end

      def on_search_button_clicked
        type = @app.get_object('search_type').active_id.to_i
        query = @app.get_object('search_entry').text
        return if query.empty?

        case type
        when TYPE_PLAYLISTS
          results = @client.search('Playlists', query)
        when TYPE_SONGS
          results = @client.search('Songs', query)
        when TYPE_PLAYLIST_ID
          playlist = Grooveshark::Playlist.new(@client, 'playlist_id' => query)
          results = playlist.load_songs
        end

        @data = {}
        @store = @app.get_object('search_list_store')
        @store.clear
        results.each do |element|
          iter = @store.append
          iter[COLUMN_CHECKBOX] = false
          if element.is_a?(Grooveshark::Song)
            @data[element.id.to_i] = element
            iter[COLUMN_ID] = element.id.to_i
            iter[COLUMN_NAME] = element.name
            iter[COLUMN_AUTHOR] = element.artist
            iter[COLUMN_SONG] = element.album
          else
            @data[element.id.to_i] = element
            iter[COLUMN_ID] = element.id.to_i.to_i
            iter[COLUMN_NAME] = element.name
            iter[COLUMN_AUTHOR] = element.username
            iter[COLUMN_SONG] = element.num_songs.to_s
          end
        end
      end

      def on_search_list_toggle_toggled(_cell, path_str)
        path = Gtk::TreePath.new(path_str)
        iter = @store.get_iter(path)
        fixed = iter[COLUMN_CHECKBOX]
        fixed ^= 1
        iter[COLUMN_CHECKBOX] = fixed
      end

      def on_search_list_selected_clicked
        @store.each do |_model, _path, iter|
          fixed = iter[COLUMN_CHECKBOX]
          fixed ^= 1
          iter[COLUMN_CHECKBOX] = fixed
        end
      end
    end
  end
end
