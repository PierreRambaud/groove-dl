# -*- coding: utf-8 -*-
module GrooveDl
  # Downloader Class
  class Displayer
    attr_reader :result, :type

    ##
    # Initialize Displayer
    #
    # @params [Array] result The result from the search
    # @params [String] type The search type
    #
    # @return [Nil]
    #
    def initialize(result, type)
      @result = result
      @type = type
    end

    ##
    # Display prompt to choose songs or playlists.
    #
    def render
      table = Terminal::Table.new(headings: headers, title: @type)
      idx = 0
      @result.each do |data|
        add_row(table, idx, data)
        idx += 1
      end

      puts table
    end

    def headers
      return %w(Id Album Artist Song) if @type == 'Songs'
      return %w(Id Nam Author NumSongs) if @type == 'Playlists'
    end

    ##
    # Add row into table
    #
    # @params [Terminal::Table] table Table in which row will be added
    # @params [Array] result The result from the search
    #
    # @return [Nil]
    #
    def add_row(table, idx, data)
      table.add_row([idx,
                     data['name'],
                     data['f_name'],
                     data['num_songs']]) if @type == 'Playlists'
      table.add_row([idx,
                     data.album,
                     data.artist,
                     data.name]) if @type == 'Songs'
    end
  end
end
