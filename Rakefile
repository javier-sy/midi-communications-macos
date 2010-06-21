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