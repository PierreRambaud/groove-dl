# -*- coding: utf-8 -*-
require 'spec_helper'
require 'groove-dl/cli'
require 'slop'

# Groove Dl tests
module GrooveDl
  # CLI tests
  module CLI
    describe 'CLI' do
      it 'should return options' do
        options = CLI.options
        expect(options).to be_a(::Slop)
        expect(options.config[:strict]).to be_truthy
        expect(options.config[:banner])
          .to eq('Usage: groove-dl [COMMAND] [OPTIONS]')
        expect(options.to_s)
          .to match(/-v, --version(\s+)Shows the current version/)
        expect(options.to_s)
          .to match(/-h, --help(\s+)Display this help message./)

        version = options.fetch_option(:v)
        expect(version.short).to eq('v')
        expect(version.long).to eq('version')
        expect { version.call }.to output(/Groove-dl v.* on ruby/).to_stdout
      end

      it 'should retrieve version information' do
        expect(CLI.version_information).to eq(
          "Groove-dl v#{VERSION} on #{RUBY_DESCRIPTION}"
        )
      end

      it 'should download playlist' do
        allow(Grooveshark::Client).to receive(:new).and_return(true)
        downloader = double
        allow(downloader).to receive(:playlist).with(1).and_return(true)
        allow(Downloader).to receive(:new).and_return(downloader)
        expect(CLI.options.parse %w( -p 1)).to eq(['-p', '1'])
      end

      it 'should do nothing if v option is passed' do
        expect(CLI.options).to receive(:puts).with(/Groove-dl v.* on ruby/)
          .and_return(nil)
        expect(CLI.options.parse %w( -v)).to eq(['-v'])
      end
    end
  end
end
