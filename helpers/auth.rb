module AuthenticationUtils

	def valid_username(username) 
		/^[a-zA-Z0-9][a-zA-Z0-9_]*$/ =~ username 
	end

	def exists_user(username)
		Player.find_by username: username
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

	def permission_error()
		status 400
		@error = "El usuario no posee permisos para realizar esta accion"
		erb 'error'.to_sym
	end
	
end