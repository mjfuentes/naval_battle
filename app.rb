require 'bundler'
require 'sinatra/json'
require './helpers/auth'
ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/*.rb'].each {|f| require f }

class Application < Sinatra::Base
	register Sinatra::ActiveRecordExtension
	enable :sessions
	configure :production, :development do
	enable :logging
	end
	helpers AuthenticationUtils
	set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

	get '/' do
		redirect '/index'
	end

	get '/logout' do
		session.clear
		redirect '/'
	end

	get '/login' do
		erb 'login'.to_sym
	end

	get '/register_form' do
		erb 'register'.to_sym
	end

	get '/index' do
		if (!session[:userid]) then
			erb 'welcome'.to_sym
		else
			redirect '/players/' + session[:userid].to_s
		end
	end

	post '/login' do
		player = Player.find_by username: params[:username], password: params[:password]
		if (player) then
			session[:username] = player.username
			session[:userid] = player.id
			redirect '/players/' + player.id.to_s
		else
			status 403
			@error = "Usuario o contraseña invalida"
			erb 'error'.to_sym
		end
	end
end
