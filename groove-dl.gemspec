# -*- coding: utf-8 -*-
require File.expand_path('../lib/groove-dl/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'groove-dl'
  s.version = GrooveDl::VERSION
  s.authors = ['Pierre Rambaud']
  s.email = 'pierre.rambaud86@gmail.com'
  s.license = 'GPL-3.0'
  s.summary = 'Grooveshark songs downloader.'
  s.homepage = 'http://github.com/PierreRambaud/groove-dl'
  s.description = 'Grooveshark downloader allow you to search, choose ' \
                  'playlists and songs and download them.'
  s.executables = ['groove-dl']

  s.files = File.read(File.expand_path('../MANIFEST', __FILE__)).split("\n")

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'slop', '~>3.6'
  s.add_dependency 'grooveshark', '~>0.2.12'
  s.add_dependency 'ruby-progressbar', '~>1.7.0'
  s.add_dependency 'terminal-table', '~>1.4.5'
  s.add_dependency 'gtk3', '~>2.2'

  s.add_development_dependency 'fakefs', '~>0.6.0'
  s.add_development_dependency 'rake', '~>10.0'
  s.add_development_dependency 'rack-test', '~>0.6'
  s.add_development_dependency 'rspec', '~>3.0'
  s.add_development_dependency 'simplecov', '~>0.9'
  s.add_development_dependency 'rubocop', '~>0.25'
end
