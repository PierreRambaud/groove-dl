# -*- coding: utf-8 -*-
require 'spec_helper'
require 'grooveshark'
require 'ruby-progressbar'
require 'fakefs/spec_helpers'
require 'groove-dl/downloader'
require 'groove-dl/errors'
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

    it 'should download playlist' do
      allow(@client).to receive(:request)
        .and_return('songs' => [{ 'song_id' =>  1,
                                  'name' => 'test',
                                  'artist_name' => 'got',
                                  'album_name' => 'ruby' }])
      allow(@client).to receive(:get_stream_auth_by_songid)
        .with(1).and_return({})
      allow(@client).to receive(:get_song_url_by_id)
        .with(1).and_return('http://test/stream?key=something')

      allow(RestClient::Request).to receive(:execute)
        .and_return(true)

      expect(@downloader.playlist('1'))
        .to eq(skipped: 0, downloaded: 0)
    end

    it 'should download song' do
      allow(@client).to receive(:get_stream_auth_by_songid)
        .with(1).and_return({})
      allow(@client).to receive(:get_song_url_by_id)
        .with(1).and_return('http://test/stream?key=something')

      allow(RestClient::Request).to receive(:execute)
        .and_return(true)

      expect(@downloader.song(1))
        .to eq(skipped: 0, downloaded: 0)
    end

    it 'should process response in cli mode' do
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

      expect(@downloader.process_cli_response('/tmp/got-test.mp3')
               .call(response))
        .to eq(1)

      expect(File.read('/tmp/got-test.mp3')).to eq('somethingnested')
    end

    it 'should process response in cli mode and does not download twice' do
      Dir.mkdir('/tmp')
      response = double
      allow(response).to receive(:[])
        .with('content-length').and_return('15')
      allow(response).to receive(:read_body)
        .and_yield('something')
        .and_yield('nested')

      File.open('/tmp/got-test.mp3', 'w') do |f|
        f.write('somethingnested')
      end

      expect do
        @downloader.process_cli_response('/tmp/got-test.mp3')
          .call(response)
      end.to raise_error(Errors::AlreadyDownloaded,
                         '/tmp/got-test.mp3 already downloaded')
    end

    it 'should process response in gui mode' do
      Dir.mkdir('/tmp')
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PATH', 0)
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PGBAR_VALUE', 1)
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PGBAR_TEXT', 2)
      iter = []
      iter[0] = '/tmp/got-test.mp3'
      response = double
      allow(response).to receive(:[])
        .with('content-length').and_return('15')
      allow(response).to receive(:read_body)
        .and_yield('something')
        .and_yield('nested')

      expect(@downloader.process_gui_response(iter)
               .call(response))
        .to eq('Complete')

      expect(iter[1]).to eq(100)
      expect(iter[2]).to eq('Complete')

      expect(File.read('/tmp/got-test.mp3')).to eq('somethingnested')
    end

    it 'should process response in gui mode and does not download twice' do
      Dir.mkdir('/tmp')
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PATH', 0)
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PGBAR_VALUE', 1)
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PGBAR_TEXT', 2)
      iter = []
      iter[0] = '/tmp/got-test.mp3'
      response = double
      allow(response).to receive(:[])
        .with('content-length').and_return('15')
      allow(response).to receive(:read_body)
        .and_yield('something')
        .and_yield('nested')

      File.open('/tmp/got-test.mp3', 'w') do |f|
        f.write('somethingnested')
      end

      expect do
        @downloader.process_gui_response(iter)
          .call(response)
      end.to raise_error(Errors::AlreadyDownloaded,
                         '/tmp/got-test.mp3 already downloaded')

      expect(iter[1]).to eq(100)
      expect(iter[2]).to eq('Complete')

      expect(File.read('/tmp/got-test.mp3')).to eq('somethingnested')
    end

    it 'should download in gui mode' do
      @downloader.type = 'gui'
      Dir.mkdir('/tmp')
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PATH', 0)
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PGBAR_VALUE', 1)
      stub_const('Widgets::DownloadList::QUEUE_COLUMN_PGBAR_TEXT', 2)
      iter = []
      iter[0] = '/tmp/got-test.mp3'

      allow(@client).to receive(:get_stream_auth_by_songid)
        .with(1).and_return({})
      allow(@client).to receive(:get_song_url_by_id)
        .with(1).and_return('http://test/stream?key=something')

      head_return = double
      allow(head_return).to receive(:headers)
        .and_return(content_length: nil)

      allow(RestClient).to receive(:head)
        .and_return(head_return)

      allow(RestClient::Request).to receive(:execute)
        .and_return(true)

      song = Grooveshark::Song.new('song_id' => 1)
      expect(@downloader.download(song, iter))
        .to eq(true)
    end
  end
end
