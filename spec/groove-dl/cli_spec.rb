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
    end
  end
end
