require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'
db_options = YAML.load_file('config/database.yml')[ENV['RACK_ENV']]
ActiveRecord::Base.establish_connection(db_options)

require './app'