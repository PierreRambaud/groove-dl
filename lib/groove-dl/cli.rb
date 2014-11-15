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

        on :s=, :song=, 'Song'
        on :p=, :playlist=, 'Playlist'
        on :a=, :artist=, 'Artist'
        on :o=, :output=, 'Output directory'

        run do |opts, args|
          puts opts[:s]
          puts args

          d = Downloader.new
          d.playlist('98625672')
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
