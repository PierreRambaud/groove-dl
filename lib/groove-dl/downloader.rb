# -*- coding: utf-8 -*-
module GrooveDl
  # Downloader Class
  class Downloader
    attr_writer :client
    attr_writer :download_queue
    attr_writer :download_count
    attr_writer :download_skip

    def initialize(client, options = {})
      @client = client
      @output_directory = options[:o] || Dir.tmpdir
      @download_queue = []
      @download_count = 0
      @download_skip = 0
    end

    def playlist(playlist_id)
      playlist = @client.request('getPlaylistByID',
                                 playlistID: playlist_id)
      return false unless playlist.key?('songs')
      playlist['songs'].each do |song|
        @download_queue << Grooveshark::Song.new(song)
      end

      download_queue
    end

    def download(song, filename)
      url = URI.parse(@client.get_song_url_by_id(song.id))
      @client.get_stream_auth_by_songid(song.id)

      block = proc do |response|
        pbar = ProgressBar.create(title: filename.split('/').last,
                                  format: '%a |%b>>%i| %p%% %t',
                                  total: response['content-length'].to_i)
        File.open(filename, 'w') do |f|
          response.read_body do |chunk|
            f.write(chunk)
            pbar.progress += chunk.length
          end
        end

        pbar.finish
        @download_count += 1
      end

      RestClient::Request
        .execute(method: :get,
                 url: url.to_s,
                 block_response: block)
    end

    def download_queue
      return false if @download_queue.empty?
      @download_queue.each do |song|
        f = sprintf('%s/%s-%s.mp3',
                    @output_directory,
                    song.artist,
                    song.name)
        if File.exist?(f)
          @download_skip += 1
        else
          download(song, f)
        end
      end
    end
  end
end
