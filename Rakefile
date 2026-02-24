require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc "Run the main application"
task :run do
  ruby 'lib/cupsem/main.rb'
end

desc "Install dependencies"
task :install do
  system 'bundle install'
end

desc "Check code style"
task :lint do
  system 'rubocop lib/'
end

desc "Generate documentation"
task :doc do
  # Could use rdoc or yard
  puts "Documentation generation not yet implemented"
end
