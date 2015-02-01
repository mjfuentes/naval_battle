Dir['../models/*.rb'].each {|f| require f }

module GameUtils

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

	def participating_games(user_id)
		games = Game.where("(creator = ? OR rival = ?) AND (status = ? OR status = ?)", session[:userid],session[:userid], 0, 1)
		games ? games : []
	end

	def rivals(user_id)
		rivals = Player.where("id != ? ", user_id)
		rivals ? rivals : []
	end

end