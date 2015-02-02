# require './config/environment'
require 'bundler/setup'
require 'rake/testtask'
require "sinatra/activerecord/rake"
 require "./mainController"


Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

task default: :test
