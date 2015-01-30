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

	before '/players/:userid*' do
  		if (session[:userid]) then
  			if  !(params[:userid] && (Integer(session[:userid]) == Integer(params[:userid]))) then
	  			@error = "No posee permisos para realizar esta accion"
	  			halt 401, erb('error'.to_sym)
	  		end
  		else
  			redirect '/'
  		end
	end

	get '/' do
		redirect '/index'
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

	get '/players/:userid' do
		session[:userid].to_s + ' ' + params[:userid].to_s
		@username = session[:username]
		@userid = session[:userid]
		@rivals = Player.where("id != ? ", session[:userid])
		@games = Game.where("(creator = ? OR rival = ?) AND (status = ? OR status = ?)", session[:userid],session[:userid], 0, 1)
		if (!@games) then
			@games = []
		end
		erb 'main'.to_sym
	end

	get '/players/:id/games' do
		if (allowed_user_id(params[:id])) then
			games = Game.where("(creator = ? OR creator = ?) AND (status = ? OR status = ?)", session[:userid],session[:userid], 0, 1)
			json games
		else
			permission_error()
		end
	end

	get '/players/:id/games/:game_id' do
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

	put '/players/:id/games/:game_id' do
		positions = Game_position.create(user_id: params[:id], game_id: params[:game_id], positions: params[:positions])
		game = Game.find_by id: params[:game_id]
		rival_id = get_rival(params[:id], game)
		rival_position = Game_position.find_by user_id: rival_id, game_id: params[:game_id]
		if (rival_position) then 	
			game.start
		end
		status 200
	end

	post '/players/:id/games/:game_id/move' do
		game = Game.find_by id: params[:game_id]
		result = {}
		if (game.status == 1) then
			if (game.turn == session[:userid]) then
				target = [params[:position][0],params[:position][1]]
				rival_position = Game_position.find_by user_id: params[:rival], game_id: params[:game_id]
				if (rival_position.positions.has_value?(target)) then
					rival_position.delete(position)
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

	post '/players' do
		begin
			player = Player.create(name: params[:name],username: params[:username], password: params[:password])
			session[:username] = player.username
			session[:userid] = player.id
			status 201
			@username = player.username
			@error = "Usuario creado exitosamente"
			erb 'error'.to_sym
		rescue Exception => e
			status 403
			@error = "Hubo un error en la creacion del usuario"
			erb 'error'.to_sym
		end
	end

	post '/players/:userid/games' do
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

	# def allowed_user_id(user_id)
	# 	if (Integer(user_id) == session[:userid]) then
	# 		true
	# 	else
	# 		false
	# 	end
	# end

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
