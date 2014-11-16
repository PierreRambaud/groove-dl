# -*- coding: utf-8 -*-
module GrooveDl
  # Downloader Class
  class Downloader
    attr_writer :client
    attr_writer :download_queue
    attr_writer :download_count
    attr_writer :download_skip

    def initialize
      @client = Grooveshark::Client.new
      @download_queue = []
      @download_count = 0
      @download_skip = 0
      @output_directory = Dir.tmpdir
    end

    def playlist(playlist_id)
      @client.request('getPlaylistByID',
                      playlistID: playlist_id)['songs'].each do |s|
        @download_queue << s
      end

      download_queue
    end

    def download(song, filename)
      url = URI.parse(@client.get_song_url_by_id(song['song_id']))
      @client.get_stream_auth_by_songid(song['song_id'])
      @counter = 0

      block = proc do |response|
        pbar = ProgressBar.new(filename.split('/').last,
                               response['content-length'].to_i)
        File.open(filename, 'w') do |f|
          response.read_body do |chunk|
            f.write(chunk)
            @counter += chunk.length
            pbar.set(@counter)
          end
        end
      end

      RestClient::Request
        .execute(method: :get,
                 url: url.to_s,
                 block_response: block)
      pbar.finish
      @download_count += 1
    rescue
      configuration.logger.error('Download cancelled. File Deleted.')
    end

    def download_queue
      return false if @download_queue.empty?
      @download_queue.each do |song|
        f = sprintf('%s/%s-%s.mp3',
                    @output_directory,
                    song['artist_name'],
                    song['name'])
        if File.exist?(f)
          @download_skip += 1
        else
          download(song, f)
        end
      end
    end
  end
end
