Gem::Specification.new do |s|
  s.name        = 'ffi-coremidi'
  s.version     = '0.4.4'
  s.date        = '2021-10-27'
  s.summary     = 'Realtime MIDI IO with Ruby for OSX'
  s.description = 'Access the Apple Core MIDI framework API with Ruby.'
  s.authors     = ['Javier Sánchez Yeste']
  s.email       = ['javier.sy@gmail.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.homepage    = 'http://rubygems.org/gems/musa-dsl'
  s.license     = 'Apache-2.0'
end
