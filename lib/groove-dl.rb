# -*- coding: utf-8 -*-

require 'slop'
require 'grooveshark'
require 'ruby-progressbar'

unless $LOAD_PATH.include?(File.expand_path('../', __FILE__))
  $LOAD_PATH.unshift(File.expand_path('../', __FILE__))
end

require 'groove-dl/cli'
require 'groove-dl/downloader'
require 'groove-dl/version'
