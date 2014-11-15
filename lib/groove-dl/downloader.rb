# -*- coding: utf-8 -*-
module GrooveDl
  # Downloader Class
  class Downloader
    attr_writer :client
    attr_writer :download_queue
    attr_writer :download_count

    def initialize
      @client = Grooveshark::Client.new
      @download_queue = []
      @download_count = 0
      @output_directory = Dir.tmpdir
    end

    def playlist(playlist_id)
      @client.request('getPlaylistByID', playlistID: playlist_id)['songs'].each do |s|
        @download_queue << s
      end

      download_queue
    end

    def download(song, filename)
      wget = sprintf('wget --progress=dot -O "%s" "%s"',
                     filename,
                     @client.get_song_url_by_id(song['song_id']))
      cmd = wget + ' 2>&1 | grep --line-buffered \"%\" |' \
            "sed -u -e 's,\.,,g\' | awk '{printf(\"\b\b\b\b%4s\", $2)}'"

      begin
        IO.popen(cmd) do |p|
          puts p
          puts p.wait
        end
      rescue StandarError
        configuration.logger.error('Download cancelled. File Deleted.')
      end
    end

    def download_queue
      return false if @download_queue.empty?
      @download_queue.each do |song|
        f = sprintf('%s/%s-%s.mp3',
                    @output_directory,
                    song['artist_name'],
                    song['name'])
        unless File.exist?(f)
          download(song, f)
        else
          @download_count += 1
        end
      end
    end
  end
end
