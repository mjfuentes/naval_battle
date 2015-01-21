require 'bundler'
require_relative './models/player'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :production, :development do
    enable :logging
  end

  set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

  get '/' do
    @greet = 'Hello from sinatra!'
    erb 'hello/greet'.to_sym
  end

  get '/index' do
  	erb 'welcome'.to_sym
  end

  get '/register' do
  	erb 'register'.to_sym
  end

  post '/players' do
  	@player = Player.new(params[:username],params[:password])
  	@username = @player.name
  	erb 'main'.to_sym
  end

end
