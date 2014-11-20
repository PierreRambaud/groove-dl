# -*- coding: utf-8 -*-
require 'spec_helper'
require 'grooveshark'
require 'ruby-progressbar'
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

    it 'should download songs' do
      allow(@client).to receive(:request)
        .and_return('songs' => [{ 'song_id' =>  1,
                                  'name' => 'test',
                                  'artist_name' => 'got' }])
      allow(@client).to receive(:get_stream_auth_by_songid)
        .with(1).and_return({})
      allow(@client).to receive(:get_song_url_by_id)
        .with(1).and_return('http://test/stream?key=something')

      allow(RestClient::Request).to receive(:execute)
        .and_return(true)

      expect(@downloader.playlist('1'))
        .to eq(skipped: 0, downloaded: 0)
      Dir.mkdir('/tmp')
      File.open('/tmp/got-test.mp3', 'w') do |f|
        f.write('test')
      end
      expect(@downloader.download_queue)
        .to eq(skipped: 1, downloaded: 0)
    end

    it 'should process response' do
      Dir.mkdir('/tmp')
      pbar = double
      allow(pbar).to receive(:progress).and_return(pbar)
      allow(pbar).to receive(:+).and_return(0)
      allow(pbar).to receive(:progress=).and_return(0)
      allow(pbar).to receive(:finish).and_return(true)
      allow(ProgressBar).to receive(:create)
        .with(title: 'got-test.mp3', format: '%a |%b>>%i| %p%% %t', total: 1)
        .and_return(pbar)
      response = double
      allow(response).to receive(:[])
        .with('content-length').and_return('1')
      allow(response).to receive(:read_body)
        .and_yield('something')
        .and_yield('nested')

      expect(@downloader.process_response('/tmp/got-test.mp3').call(response))
        .to eq(1)

      expect(File.read('/tmp/got-test.mp3')).to eq('somethingnested')
    end
  end
end