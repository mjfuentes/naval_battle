Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

class GameModelTest < Minitest::Test

	def player_mock
		Player.create(name: 'prueba',username: 'p12', password: '1234')
	end

	def teardown
		Player.delete_all
	end

	def test_creation
		player = player_mock
		assert_equal player.name, 'prueba'
		assert_equal player.username, 'p12'
		assert_equal player.password, '1234'
	end

end