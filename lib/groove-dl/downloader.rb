# -*- coding: utf-8 -*-
module GrooveDl
  # Downloader Class
  class Downloader
    attr_accessor :type
    attr_writer :client
    attr_writer :download_queue
    attr_writer :download_count
    attr_writer :download_skip

    ##
    # Initialize download
    #
    # @return [Downloader]
    #
    def initialize(client, options = {})
      @client = client
      @output_directory = options[:o] || Dir.tmpdir
      @queue = []
      @count = 0
      @skip = 0
      @type = 'cli'
    end

    ##
    # Download song
    #
    # @params [String] song_id Song id
    #
    # @return [Array]
    #
    def song(song_id)
      @queue << Grooveshark::Song.new('song_id' => song_id,
                                      'artist_name' => 'unknown',
                                      'song_name' => 'unknown')
      download_queue
    end

    ##
    # Download playlist
    #
    # @params [String] playlist_id Playlist id
    #
    # @return [Array]
    #
    def playlist(playlist_id)
      playlist = Grooveshark::Playlist.new(@client,
                                           'playlist_id' => playlist_id)
      songs = playlist.load_songs
      return false unless songs
      @queue += songs

      download_queue
    end

    ##
    # Download song
    #
    # @param [Grooveshark::Song] song Song object
    # @param [Gtk::TreeIter/String] callback Proc
    # function to execute during download
    #
    # @return [Net::HTTP]
    #
    def download(song, object)
      url = URI.parse(@client.get_song_url_by_id(song.id))
      @client.get_stream_auth_by_songid(song.id)

      callback = process_gui_response(object) if @type == 'gui'
      callback = process_cli_response(object) if @type == 'cli'

      RestClient::Request
        .execute(method: :get,
                 url: url.to_s,
                 block_response: callback)
    end

    ##
    # Download queue
    #
    # @return [false|Array]
    #
    def download_queue
      return false if @queue.empty?
      @queue.each do |song|
        f = build_path(@output_directory, song)
        if File.exist?(f)
          @skip += 1
        else
          download(song, f)
        end
      end

      { skipped: @skip, downloaded: @count }
    end

    ##
    # Build path
    #
    # @param [String] output_directory destination directory
    # @param [Grooveshark::Song] song Song
    #
    def build_path(output_directory, song)
      sprintf('%s/%s-%s.mp3',
              output_directory,
              song.artist,
              song.name)
    end

    ##
    # Process response to display a progress bar and download
    # file into destination.
    #
    # @param [String] destination Destination
    #
    # @return [Proc]
    #
    def process_cli_response(destination)
      proc do |response|
        pbar = ProgressBar.create(title: destination.split('/').last,
                                  format: '%a |%b>>%i| %p%% %t',
                                  total: response['content-length'].to_i)
        File.open(destination, 'w') do |f|
          response.read_body do |chunk|
            f.write(chunk)
            pbar.progress += chunk.length
          end
        end

        pbar.finish
        @count += 1
      end
    end

    ##
    # Process response to pulse progressbar stored in the
    # TreeIter object.
    #
    # @param [Gtk::TreeIter] object TreeIter
    #
    # @return [Proc]
    #
    def process_gui_response(object)
      proc do |response|
        total_size = response['content-length'].to_i
        path = object[Widgets::DownloadList::COLUMN_PATH]
        if File.exist?(path) &&
           File.size?(path) == total_size
          object[Widgets::DownloadList::COLUMN_PGBAR_VALUE] = 100
          object[Widgets::DownloadList::COLUMN_PGBAR_TEXT] = 'Complete'
          fail Errors::AlreadyDownloaded, "#{path} already downloaded"
        end

        File.open(path, 'w') do |f|
          file_size = 0
          response.read_body do |chunk|
            f.write(chunk)
            file_size += chunk.length
            result = ((file_size * 100) / total_size).to_i
            object[Widgets::DownloadList::COLUMN_PGBAR_VALUE] = result
            object[Widgets::DownloadList::COLUMN_PGBAR_TEXT] = 'Complete' if
              object[Widgets::DownloadList::COLUMN_PGBAR_VALUE] >= 100
          end
        end
      end
    end
  end
end
