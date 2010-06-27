#!/usr/bin/env ruby
#
# Rakefile for MIDIator.
#
# == Authors
#
# * Ben Bleything <ben@bleything.net>
#
# == Copyright
#
# Copyright (c) 2008 Ben Bleything
#
# This code released under the terms of the MIT license.
#

require 'rubygems'
require 'spec/rake/spectask'


task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.ruby_opts = ["-rubygems"]
  t.libs << 'lib'
  t.warning = false
  t.rcov = false
  t.spec_opts = ["--colour"]
end

namespace :spec do
  ### Run the specifications and generate coverage information
  Spec::Rake::SpecTask.new( :coverage ) do |r|
    r.rcov      = true
    r.rcov_dir  = 'coverage'
    r.rcov_opts = %w( -x Library\/Ruby,^spec,rvm )
    r.libs      << 'lib'
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'docs/rdoc'
  rdoc.title    = "MIDIator - a nice Ruby interface to your system's MIDI services."

  rdoc.options += [
    '-w', '4',
    '-SHNa',
    '-i', 'lib',
    '-m', 'README',
    '-W', 'http://projects.bleything.net/repositories/changes/midiator/',
    ]

  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include 'LICENSE'
  rdoc.rdoc_files.include 'LICENSE.prp'
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/packagetask'
require 'rake/gempackagetask'

### Task: gem
gemspec = Gem::Specification.new do |gem|
  gem.name      = "midiator"
  gem.version   = File.read('VERSION')

  gem.summary     = "MIDIator - A a nice Ruby interface to your system's MIDI services."
  gem.description = "MIDIator provides an OS-agnostic way to send live MIDI messages to " +
            "your machine's MIDI playback system."

  gem.authors  = "Ben Bleything"
  gem.email    = "ben@bleything.net"
  gem.homepage = "http://projects.bleything.net/projects/show/midiator"

  gem.rubyforge_project = 'midiator'

  gem.has_rdoc = true

  gem.files        = FileList['Rakefile', 'README.rdoc', 'examples/**/*', 'lib/**/*'].to_a
  gem.test_files   = FileList['spec/**/*.rb']

  gem.add_dependency 'Platform', [">= 0.4.0"]
end

Rake::GemPackageTask.new( gemspec ) do |task|
  task.gem_spec = gemspec
  task.need_tar = false
  task.need_tar_gz = true
  task.need_tar_bz2 = true
  task.need_zip = true
end