require 'bundler'
require 'sinatra/json'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/*.rb'].each {|f| require f }

class Application < Sinatra::Base
	register Sinatra::ActiveRecordExtension
	enable :sessions
	configure :production, :development do
	enable :logging
	end

	set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

	get '/' do
		redirect '/index'
	end

	get '/main' do
		if (session[:username]) then
			@username = session[:username]
			@userid = session[:userid]
			@rivals = Player.all
			erb 'main'.to_sym
		else
			redirect '/index'
		end
	end

	get '/index' do
		erb 'welcome'.to_sym
	end

	get '/login' do
		erb 'login'.to_sym
	end

	get '/register_form' do
		erb 'register'.to_sym
	end

	get '/players' do 
		status 200
		json Player.all
	end

	get '/players/:id/games'

	post '/login' do
		player = Player.find_by username: params[:username], password: params[:password]
		if (player != nil) then
			session[:username] = player.username
			session[:userid] = player.id
			status 201
			redirect '/main'
		else
			status 403
			@error = "Usuario o contraseña invalida"
			erb 'error'.to_sym
		end
	end

	post '/players' do
		begin
			player = Player.create(name: params[:name],username: params[:username], password: params[:password])
			session[:username] = player.username
			session[:userid] = player.id
			status 201
			@username = player.username
			redirect '/main'
		rescue Exception
			status 403
			@error = "Hubo un error en la creacion del usuario"
			erb 'error'.to_sym
		end
	end

	post '/players/:userid/games' do
		if (session[:userid] == Integer(params[:userid])) then
			rival = Player.find_by username: params[:rival]
			game = Game.create(creator: Integer(session[:userid]),rival: Integer(rival.id),size: params[:size])
			@game_id = game.id
			status 201
			json game
		else
			status 400
			@error = "El usuario no posee permisos para realizar esta accion"
			erb 'error'.to_sym
		end
	end
end
