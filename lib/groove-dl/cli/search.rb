# -*- coding: utf-8 -*-
GrooveDl::CLI.options.command 'search' do
  banner 'Usage: groove-dl search [OPTIONS]'
  description 'Search for something on GrooveShark'
  separator "\nOptions:\n"

  on :p=, :playlist=, 'Playlist', as: String
  on :s=, :song=, 'Song', as: String

  run do |opts|
    next if opts[:p].nil? && opts[:a].nil? && opts[:s].nil?
    client = Grooveshark::Client.new

    type = 'Songs' if opts[:s]
    type = 'Playlists' if opts[:p]
    query = opts[:s] if opts[:s]
    query = opts[:p] if opts[:p]

    results = client.request('getResultsFromSearch',
                             type: type,
                             query: query)['result']
    results.map! do |data|
      next Grooveshark::Song.new data if type == 'Songs'
      data
    end

    displayer = GrooveDl::Displayer.new(results, type)
    displayer.render
  end
end
