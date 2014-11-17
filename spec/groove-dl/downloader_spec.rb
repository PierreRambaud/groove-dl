# -*- coding: utf-8 -*-
require 'spec_helper'
require 'grooveshark'
require 'fakefs/spec_helpers'
require 'groove-dl/downloader'
require 'slop'

# Groove Dl tests
module GrooveDl
  # Downloader test
  describe 'Downloader' do
    include FakeFS::SpecHelpers

    before(:each) do
      @client = double
      @downloader = Downloader.new(@client, {})
    end

    it 'should do nothing if playlist not found' do
      allow(@client).to receive(:request).and_return({})
      expect(@downloader.playlist(1)).to be_falsy
    end

    it 'should do nothing if queue is empty' do
      expect(@downloader.download_queue).to be_falsy
    end

    # it 'should download songs' do
    #   allow(@client).to receive(:request)
    #     .and_return('songs' => [{ 'song_id' =>  1,
    #                               'name' => 'test',
    #                               'artist_name' => 'got' }])
    #   allow(@client).to receive(:get_stream_auth_by_songid)
    #     .with(1).and_return({})
    #   allow(@client).to receive(:get_song_url_by_id)
    #     .with(1).and_return('http://test/stream?key=something')
    #   expect(@downloader.playlist('1')).to be_falsy
    # end
  end
end
