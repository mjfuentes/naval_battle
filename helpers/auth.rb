module AuthenticationUtils

	def valid_username(username) 
		/^[a-zA-Z0-9][a-zA-Z0-9_]*$/ =~ username 
	end

	def exists_user(username)
		Player.find_by username: username
	end

	def allowed_user(user_id, game_id)
		if (Integer(user_id) == session[:userid]) then
			Game.where("(creator = ? OR rival = ?) AND id = ?", session[:userid],session[:userid], game_id).any?
		else
			false
		end
	end

	def permission_error()
		status 400
		@error = "El usuario no posee permisos para realizar esta accion"
		erb 'error'.to_sym
	end

	def incorrect_parameters()
		status 400
		@error = "Parametros incorrectos"
		erb 'error'.to_sym
	end
	
end