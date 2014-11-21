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
      song = Grooveshark::Song.new('song_id' =>  1,
                                   'name' => 'test',
                                   'artist_name' => 'got')
      @displayer = Displayer.new([song], 'Songs')
    end

    it 'should initialize' do
      expect(@displayer.type).to eq('Songs')
      expect(@displayer.result.first).to be_a(Grooveshark::Song)
    end

    it 'should render table' do
      allow(@displayer).to receive(:puts).and_return(nil)
      expect(@displayer.render).to be_nil
    end
  end
end
