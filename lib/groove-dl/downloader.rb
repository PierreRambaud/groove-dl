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
    # @param [String] song_id Song id
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
    # @param [String] playlist_id Playlist id
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
        download(song, build_path(@output_directory, song))
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
      format('%s/%s/%s/%s.mp3',
             output_directory,
             song.artist,
             song.album,
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
        total_size = response['content-length'].to_i
        if File.exist?(destination) &&
           File.size?(destination) == total_size

          @skip += 1
          fail Errors::AlreadyDownloaded, "#{destination} already downloaded"
        end

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
        pgbar_value = Widgets::Download::QUEUE_COLUMN_PGBAR_VALUE
        pgbar_text = Widgets::Download::QUEUE_COLUMN_PGBAR_TEXT

        total_size = response['content-length'].to_i
        path = object[Widgets::Download::QUEUE_COLUMN_PATH]
        if File.exist?(path) &&
           File.size?(path) == total_size
          object[pgbar_value] = 100
          object[pgbar_text] = 'Complete'
          fail Errors::AlreadyDownloaded, "#{path} already downloaded"
        end

        dirname = File.dirname(path)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

        File.open(path, 'w') do |f|
          file_size = 0
          response.read_body do |chunk|
            f.write(chunk)
            file_size += chunk.length
            result = ((file_size * 100) / total_size).to_i
            object[pgbar_value] = result
            object[pgbar_text] = 'Complete' if
              object[pgbar_value] >= 100
          end
        end
      end
    end
  end
end
