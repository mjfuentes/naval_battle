require './config/environment'
require 'bundler/setup'
require 'rake/testtask'
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./app"
  end
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

task default: :test
