Gem::Specification.new do |s|
  s.name        = 'midi-communications-macos'
  s.version     = '0.5.0'
  s.date        = '2021-11-15'
  s.summary     = 'Realtime MIDI IO with Ruby for OSX'
  s.description = 'Access the Apple Core MIDI framework API with Ruby.'
  s.authors     = ['Javier Sánchez Yeste']
  s.email       = ['javier.sy@gmail.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.homepage    = 'http://rubygems.org/gems/midi-communications-macos'
  s.license     = 'LGPL-3.0'

  s.required_ruby_version = '~> 2.7'

  s.add_runtime_dependency 'ffi', '~> 1.15', '>= 1.15.4'

  # TODO
  #s.metadata    = {
  # "source_code_uri" => "https://",
  # "homepage_uri" => "",
  # "documentation_uri" => "",
  # "changelog_uri" => ""
  #}
end
