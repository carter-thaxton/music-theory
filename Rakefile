require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task :console do
  require 'irb'
  require 'music-theory'
  include MusicTheory
  ARGV.clear
  IRB.start
end

task :default => :test
