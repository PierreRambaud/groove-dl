# -*- coding: utf-8 -*-
require 'spec_helper'
require 'grooveshark'
require 'terminal-table'
require 'fakefs/spec_helpers'
require 'groove-dl/displayer'

# Groove Dl tests
module GrooveDl
  # Downloader test
  describe 'Displayer' do
    include FakeFS::SpecHelpers

    before(:each) do
    end

    it 'should initialize' do
      song = Grooveshark::Song.new('song_id' =>  1,
                                   'name' => 'test',
                                   'artist_name' => 'got')
      displayer = Displayer.new([song], 'Songs')
      expect(displayer.type).to eq('Songs')
      expect(displayer.result.first).to be_a(Grooveshark::Song)
    end

    it 'should render songs' do
      song = Grooveshark::Song.new('song_id' =>  1,
                                   'name' => 'test',
                                   'artist_name' => 'got')
      displayer = Displayer.new([song], 'Songs')

      str = '+----+-------+--------+------+
|           Songs            |
+----+-------+--------+------+
| Id | Album | Artist | Song |
+----+-------+--------+------+
| 1  |       | got    | test |
+----+-------+--------+------+'
      allow(displayer).to receive(:puts)
        .with(str).and_return(nil)
      expect(displayer.render).to be_nil
    end

    it 'should render songs' do
      playlist = { 'playlist_id' => 1,
                   'name' => 'Someting',
                   'f_name' => 'GoT',
                   'num_songs' => 1 }
      displayer = Displayer.new([playlist], 'Playlists')

      str = '+----+----------+--------+----------+
|             Playlists             |
+----+----------+--------+----------+
| Id | Nam      | Author | NumSongs |
+----+----------+--------+----------+
| 1  | Someting | GoT    | 1        |
+----+----------+--------+----------+'
      allow(displayer).to receive(:puts)
        .with(str).and_return(nil)
      expect(displayer.render).to be_nil
    end
  end
end
