Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

class PositionModelTest < Minitest::Test

	def position_mock
		Game_position.create(user_id: 1, game_id: 1, positions: {"0" => [1,1],"1" => [2,2]})
	end

	def teardown
		Game_position.delete_all
	end

	def test_create
		positions = position_mock
		assert_equal positions.user_id, 1
		assert_equal positions.game_id, 1
		assert_equal positions.positions, {"0" => [1,1],"1" => [2,2]}
	end

	


end