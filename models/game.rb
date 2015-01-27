class Game
	attr_accessor :players,:size,:started,:id

	def initialize(creator,size)
		@players = [creator]
		@size = size
		@started = false
		@id = save_game()
	end

	def save_game()
		1
	end

	def add_second_player(player)
		@players[1] = player
	end

	def start()
		started = true
		update()
	end

	def update()

	end
end