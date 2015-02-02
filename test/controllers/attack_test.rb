Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

require 'json'
require 'minitest/autorun'
require File.expand_path '../../../gameController', __FILE__

class AttackTests < Minitest::Test
	include Rack::Test::Methods			

	def app
		GameController
	end

	def setup
		@game = mock_game(3,8)
	end

	def teardown
		Game.delete_all
		Game_position.delete_all
	end
	
	def mock_game creator,rival
		Game.create(creator: creator,rival: rival,size: 'small')
	end

	def mock_positions user,game
		Game_position.create(user_id: user, game_id: game, positions: {"0" => [1,1]})
	end

	def test_attack_hit
		Game_position.create(user_id: 8, game_id: @game.id, positions: {"0" => [1,1],"1" => [2,2]})
		@game.start
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,1], :rival => 8}, 'rack.session' => { :userid => 3 }
		assert_equal 201, last_response.status
		resultado = JSON.parse(last_response.body)
		assert_equal 2, resultado['code']
	end

	def test_attack_hit_game_won
		@game.start
		mock_positions(8,@game.id)
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,1], :rival => 8}, 'rack.session' => { :userid => 3 }
		assert_equal 201, last_response.status
		resultado = JSON.parse(last_response.body)
		assert_equal 3, resultado['code']
	end

	def test_attack_miss
		Game_position.create(user_id: 3, game_id: @game.id, positions: {"0" => [1,1],"1" => [2,2]})
		@game.start
		mock_positions(8,@game.id)
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,4], :rival => 8}, 'rack.session' => { :userid => 3 }
		assert_equal 201, last_response.status
		resultado = JSON.parse(last_response.body)
		assert_equal 1, resultado['code']
	end

	def test_attack_incorrect_turn
		@game.start
		@game.move_made
		mock_positions(8,@game.id)
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,1], :rival => 8}, 'rack.session' => { :userid => 3 }
		assert_equal 403, last_response.status
		resultado = JSON.parse(last_response.body)
		assert_equal 0, resultado['code']
	end

	def test_attack_game_not_started
		mock_positions(8,@game.id)
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,1], :rival => 8}, 'rack.session' => { :userid => 3 }
		assert_equal 403, last_response.status
		resultado = JSON.parse(last_response.body)
		assert_equal 0, resultado['code']
	end

	def test_attack_invalid_user
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,1], :rival => 8}, 'rack.session' => { :userid => 4 }
		assert_equal 401, last_response.status
	end

	def test_attack_not_logged_in
		mock_positions(8,@game.id)
		post '/3/games/' + @game.id.to_s + '/move', {:position => [1,1], :rival => 8}
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/', last_request.url
	end

	def test_attack_incorrect_parameters
		mock_positions(8,@game.id)
		@game.start
		post '/3/games/' + @game.id.to_s + '/move', {:positionasd => [1,1]}, 'rack.session' => { :userid => 3 }
		assert_equal 400, last_response.status
	end

end