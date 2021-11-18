$LOAD_PATH.prepend __dir__
$LOAD_PATH.prepend File.join(__dir__, 'lib')

require 'rake'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task default: [:test]
