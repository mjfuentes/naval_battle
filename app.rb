require 'bundler'

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

	get '/index' do
		erb 'welcome'.to_sym
	end

	get '/login' do
		erb 'login'.to_sym
	end

	get '/register_form' do
		erb 'register'.to_sym
	end

	post '/login' do
		player = loadPlayer(params[:username],params[:password])
		@session[:username] = player.username
		username = player.username
		name = player.name
		erb 'main'.to_sym
	end

	post '/register' do
		player = Player.new(params[:name],params[:username],params[:password])
		player.save
		@session[:username] = player.username
		username = player.username
		name = player.name
		erb 'main'.to_sym
	end

	get '/new/:user/:size' do
		if (@session[:username] == params[:user]) then
			game = Game.new(:user,:size)
			erb 'waiting'.to_sym
		else
			username = @session[:username]
			second_username = params[:user]
			erb 'permission_error'.to_sym
		end

	end

	get '/join/:user' do
		if (session[:username] == params[:user]) then
			game = getWaitingGame()
			game.add_second_player(params[:user])
			game.start()
			rival = game.players[0]
			cell_amount = 5
			cell_size = (cell_amount / 500).round
			ship_amount = 3
			erb 'game'.to_sym
		else
			@username = session[:username]
			@second_username = params[:user]
			erb 'permission_error'.to_sym
		end
	end


	def loadPlayer(username,password)
		Player.new("generico","1234","1234")
	end

	def getWaitingGame()
		game = Game.new("pepito", "small")
	end
end
