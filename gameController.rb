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
			begin
	  			if  !(params[:userid] && (Integer(session[:userid]) == Integer(params[:userid]))) then
		  			@error = "No posee permisos para realizar esta accion"
		  			halt 401, erb('error'.to_sym)
		  		end
		  	rescue Exception => e
				@error = "Parametros invalidos"
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
		if (session[:userid]) then
			@players = Player.all.collect do |p| p.username end
			status 200
			erb 'players'.to_sym
		else
			permission_error
		end
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
				@error = "Game already finished!" 
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
		begin
			game = Game.find_by id: params[:game_id]
			if (game.status == 0) then
				positions = Game_position.create(user_id: params[:id], game_id: params[:game_id], positions: params[:positions])
				rival_id = get_rival(params[:id], game)
				rival_position = Game_position.find_by user_id: rival_id, game_id: params[:game_id]
				if (rival_position) then 	
					game.start
				end
				status 200
			else
				status 400
				@error = "Game already started, cannot set ships"
				erb 'error'.to_sym
			end
		rescue Exception => e
			status 400
			@error = "Hubo un error al crear los barcos"
			erb 'error'.to_sym
		end
	end

	post '/:id/games/:game_id/move' do
		begin
			game = Game.find_by id: params[:game_id]
			result = {}
			case game.status
			when 1 
				if (game.is_turn?(session[:userid])) then
					target = [Integer(params[:position][0]),Integer(params[:position][1])]
					rival_position = Game_position.find_by user_id: params[:rival], game_id: params[:game_id]
					if (rival_position.hit?(target)) then
						if (rival_position.done?) then
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
					result["message"] = "It's not your turn!" 
					result["code"] = 0 
					status 403
				end
			when 0
				result["message"] = "Game has not started yet!" 
				result["code"] = 0
				status 403
			when 2
				if (game.winner == session[:userid]) then
					result["message"] = "You won!"
					result["code"] = 1
				else
					result["message"] = "You lost!"
					result["code"] = 2
				end
				status 403
			end
			json result
		rescue Exception => e
			status 400
			@error = "Hubo un error al generar el ataque"
			erb 'error'.to_sym
		end
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
end
