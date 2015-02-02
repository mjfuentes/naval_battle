Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

class GameModelTest < Minitest::Test

	def game_mock
		Game.create(creator: 1,rival: 2,size: 'small')
	end

	def teardown
		Game.delete_all
	end

	def test_creation
		game = game_mock
		assert_equal game.status, 0
		assert_equal game.creator, 1
		assert_equal game.rival, 2
		assert_equal game.size, 'small'
		assert_equal game.turn, 0
	end

	def test_start
		game = game_mock
		assert_equal game.status, 0
		game.start
		assert_equal game.status, 1
	end

	def test_turn
		game = game_mock
		game.start
		assert game.is_turn? 1
		game.move_made
		assert(!game.is_turn?(1))
	end

	def test_end
		game = game_mock
		game.start
		game.end 2
		assert_equal game.winner, 2
		assert_equal game.loser, 1
	end

end
