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

	get '/players/:id/games' do
		if (allowed_user_id(params[:id])) then
			json Game.all
		else
			permission_error()
		end
	end

	get '/players/:id/games/:game_id' do
		if (allowed_user(params[:id],params[:game_id])) then
			json Game.find_by id: params[:game_id]
		else
			permission_error()
		end
	end

	get '/positions' do
		json Game_position.all
	end

	put '/players/:id/games/:game_id' do
		if (allowed_user(params[:id],params[:game_id])) then
			positions = Game_position.create(user_id: params[:id], game_id: params[:game_id], positions: params[:positions])
			status 200
		else
			permission_error()
		end
	end

	post '/players/:id/games/:game_id/move' do
		if (allowed_user(params[:id],params[:game_id])) then
			text = ""
			position = [params[:position][0],params[:position][1]]
			rival_position = Game_position.find_by user_id: params[:rival], game_id: params[:game_id]
			res = rival_position.positions.has_value?(position)
			if (res) then
				key = rival_position.positions.key(position)
				rival_position.positions.delete(key)
				if (rival_position.positions.length == 0) then
					text = "Ganaste!."
				else
					text = "Le diste a un barco!"
				end
			else
				text = "Agua."
			end
			status 201
			text
		else
			permission_error()
		end
	end

	# post '/players/:id/games/:game_id/move' do
	# 	if (allowed_user(params[:id],params[:game_id])) then
	# 		# text = ""
	# 		# position = [params[:position][1],params[:position][3]]
	# 		json params[:position]
	# 	else
	# 		permission_error()
	# 	end
	# end

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
		if (allowed_user_id(params[:userid])) then
			rival = Player.find_by username: params[:rival]
			game = Game.create(creator: Integer(session[:userid]),rival: Integer(rival.id),size: params[:size])
			@game_id = game.id
			@user_id = session[:userid]
			@game_size = game.size
			@rival_id = rival.id
			@rival = game.rival
			status 201
			erb 'game'.to_sym
		else
			permission_error()
		end
	end

	def allowed_user_id(user_id)
		if (Integer(user_id) == session[:userid]) then
			true
		else
			false
		end
	end

	def permission_error()
		status 400
		@error = "El usuario no posee permisos para realizar esta accion"
		erb 'error'.to_sym
	end

	def allowed_user(user_id, game_id)
		if (allowed_user_id(user_id)) then
			game = Game.find_by id: game_id, creator: user_id
			if (game == nil) then
				game = Game.find_by id: game_id, rival: user_id
				if (game == nil) then
					false
				end
			end
			true
		end
	end
end
