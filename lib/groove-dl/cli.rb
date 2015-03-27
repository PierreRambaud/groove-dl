# -*- coding: utf-8 -*-
module GrooveDl
  # CLI module
  module CLI
    ##
    # Hash containing the default Slop options.
    #
    # @return [Hash]
    #
    SLOP_OPTIONS = {
      strict: true,
      help: true,
      banner: 'Usage: groove-dl [COMMAND] [OPTIONS]'
    }

    ##
    # @return [Slop]
    #
    def self.options
      @options ||= default_options
    end

    ##
    # @return [Slop]
    #
    def self.default_options
      Slop.new(SLOP_OPTIONS.dup) do
        separator "\nOptions:\n"

        on :v, :version, 'Shows the current version' do
          puts CLI.version_information
        end

        on :p=, :playlist=, 'Playlist', as: Integer
        on :s=, :song=, 'Song', as: Integer
        on :o=, :output=, 'Output directory', as: String

        run do |opts|
          next if opts[:v]

          client = Grooveshark::Client.new
          d = Downloader.new(client, opts)
          if opts[:p]
            GrooveDl.configuration.logger
              .info("Download files into #{d.output_directory}")
            d.playlist(opts[:p])
          end

          d.song(opts[:s]) if opts[:s]
        end
      end
    end

    ##
    # Returns a String containing some platform/version related information.
    #
    # @return [String]
    #
    def self.version_information
      "Groove-dl v#{VERSION} on #{RUBY_DESCRIPTION}"
    end
  end
end
