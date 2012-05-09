# encoding: utf-8

require 'rubygems'
require 'rspec/core/rake_task'

task :default => [:clear_db, :spec]

desc "Clear DB"
task "clear_db" do
  sh "mysql -u root pipes < ./db/fixture.sql"
end

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)
