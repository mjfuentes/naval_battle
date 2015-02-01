require 'bundler'
require 'sinatra/json'
require './helpers/auth'
require './helpers/game'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/*.rb'].each {|f| require f }

class GameController < Sinatra::Base
	register Sinatra::ActiveRecordExtension
	enable :sessions
	configure :production, :development do
	enable :logging
	end
	helpers AuthenticationUtils, GameUtils
	set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]

	before '/:userid*' do
  		if (session[:userid]) then
  			if  !(params[:userid] && (Integer(session[:userid]) == Integer(params[:userid]))) then
	  			@error = "No posee permisos para realizar esta accion"
	  			halt 401, erb('error'.to_sym)
	  		end
  		else
  			redirect '/'
  		end
	end

	before '/:id/games/:game_id*' do
		if (params[:game_id]) then
  			if  !(params[:game_id] && (allowed_user(session[:userid],params[:game_id]))) then
	  			@error = "No posee permisos para realizar esta accion"
	  			halt 401, erb('error'.to_sym)
	  		end
  		else
  			redirect '/'
  		end
	end

	get '/' do
		@players = Player.all.collect do |p| p.username end
		status 200
		erb 'players'.to_sym
	end

	get '/:userid' do
		@username = session[:username]
		@userid = session[:userid]
		@rivals = rivals(:userid)
		@games = participating_games(session[:userid])
		status 200
		erb 'main'.to_sym
	end

	get '/:id/games' do
		games = participating_games(session[:userid])
		status 200
		json games
	end

	get '/:id/games/:game_id' do
		if (allowed_user(params[:id],params[:game_id])) then
			game =  Game.find_by id: params[:game_id]
			positions = Game_position.find_by user_id: params[:id], game_id: params[:game_id]
			rival_id = get_rival(params[:id], game)
			if (game.status == 0 || game.status == 1) then
				status 200
				game.status = (positions == nil) ? 0 : 1
				show_game(game.id,game.size,session[:userid],rival_id,game.status)
			else
				status 400
				@error = "La partida ya finalizo!" 
				erb 'error'.to_sym
			end
		else
			permission_error()
		end
	end

	get '/:id/games/:game_id/positions' do
		positions = Game_position.find_by user_id: params[:id], game_id: params[:game_id]
		if (positions) then
			status 200
			json positions
		else
			status 400
			json "No se encontraron las posiciones guardadas"
		end	
	end

	put '/:id/games/:game_id' do
		positions = Game_position.create(user_id: params[:id], game_id: params[:game_id], positions: params[:positions])
		game = Game.find_by id: params[:game_id]
		rival_id = get_rival(params[:id], game)
		rival_position = Game_position.find_by user_id: rival_id, game_id: params[:game_id]
		if (rival_position) then 	
			game.start
		end
		status 200
	end

	post '/:id/games/:game_id/move' do
		game = Game.find_by id: params[:game_id]
		result = {}
		if (game.status == 1) then
			if (game.turn == session[:userid]) then
				target = [params[:position][0],params[:position][1]]
				rival_position = Game_position.find_by user_id: params[:rival], game_id: params[:game_id]
				if (rival_position.positions.has_value?(target)) then
					rival_position.delete(target)
					if (rival_position.positions.length == 0) then
						result["code"] = 3 
						game.end session[:userid]
					else
						result["code"] = 2 
					end
				else
					result["code"] = 1 
				end
				game.move_made
				status 201
			else
				result["message"] = "No es tu turno!"  
				status 403
			end
		elsif (game.status = 0) then
			result["message"] = "El juego todavia no comenzó!" 
			status 403
		end
		json result
	end

	post '/' do
		begin
			if (valid_username(params[:username])) then
				if (!exists_user(params[:username])) then
					player = Player.create(name: params[:name],username: params[:username], password: params[:password])
					session[:username] = player.username
					session[:userid] = player.id
					status 201
					@username = player.username
					@error = "Usuario creado exitosamente"
					erb 'error'.to_sym
				else
					status 409
					@error = "El nombre de usuario ya existe."
					erb 'error'.to_sym
				end
			else
				status 400
				@error = "El nombre de usuario no es valido"
				erb 'error'.to_sym
			end
		rescue Exception => e
			status 403
			@error = "Hubo un error en la creacion del usuario"
			erb 'error'.to_sym
		end
	end

	post '/:userid/games' do
		begin
			rival = Player.find_by username: params[:rival]
			game = Game.create(creator: Integer(session[:userid]),rival: Integer(rival.id),size: params[:size])
			status 201
			show_game(game.id,game.size,game.creator,game.rival,0)
		rescue Exception => e
			status 400
			@error = "Hubo un error en la creacion del juego"
			erb 'error'.to_sym
		end
	end

	def valid_username(username) 
		/^[a-zA-Z0-9][a-zA-Z0-9_]*$/ =~ username 
	end

	def exists_user(username)
		Player.find_by username: username
	end

	def permission_error()
		status 400
		@error = "El usuario no posee permisos para realizar esta accion"
		erb 'error'.to_sym
	end

	def allowed_user(user_id, game_id)
		if (Integer(user_id) == session[:userid]) then
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

	def get_rival(user, game)
		if (Integer(user) == Integer(game.creator))
			game.rival
		else
			game.creator
		end
	end

	def show_game(id,size,userid,rivalid,status)
		@game_id = id
		@game_size = size
		@user_id = userid
		@rival_id = rivalid
		@game_status = status
		erb 'game'.to_sym
	end
end
