Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

require 'json'
require 'minitest/autorun'
require File.expand_path '../../../gameController', __FILE__

class GameTests < Minitest::Test
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

	def test_get_player_games_not_logged_in
		get '/3/games'
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/', last_request.url
	end

	def test_get_game_creator
		get '/3/games/' + @game.id.to_s, {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_get_game_creator_positions_loaded
		mock_positions(3,@game.id)
		get '/3/games/' + @game.id.to_s, {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_get_game_rival
		get '/3/games/' + @game.id.to_s, {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_get_game_rival_positions_loaded
		mock_positions(3,@game.id)
		get '/3/games/' + @game.id.to_s, {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_get_game_invalid_user
		@game = mock_game(4,8)
		get '/3/games/' + @game.id.to_s, {}, 'rack.session' => { :userid => 3 }
		assert_equal 401, last_response.status
	end

	def test_get_game_not_logged_in
		get '/3/games/' + @game.id.to_s
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/', last_request.url
	end

	def test_get_player_positions
		mock_positions(3,@game.id)
		get '/3/games/' + @game.id.to_s + '/positions', {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
		resultado = JSON.parse(last_response.body)
		pos = {"0" => [1,1]}
		assert_equal pos, resultado['positions']
	end

	def test_get_player_positions_invalid_user
		mock_positions(3,@game.id)
		get '/4/games/' + @game.id.to_s + '/positions', {}, 'rack.session' => { :userid => 4 }
		assert_equal 401, last_response.status
	end

	def test_get_player_positions_not_logged_in
		mock_positions(3,@game.id)
		get '/3/games/' + @game.id.to_s + '/positions'
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/', last_request.url
	end

	def test_get_player_positions_not_set
		get '/3/games/' + @game.id.to_s + '/positions', {}, 'rack.session' => { :userid => 3 }
		assert_equal 400, last_response.status
	end

	def test_put_positions_valid_user
		put '/3/games/' + @game.id.to_s, {:userid => 3, :gameid => @game.id, :positions => [[1,1],[2,2]]},  'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_put_positions_invalid_user
		put '/3/games/' + @game.id.to_s, {:userid => 3, :gameid => @game.id, :positions => [[1,1],[2,2]]},  'rack.session' => { :userid => 4 }
		assert_equal 401, last_response.status
	end

	def test_put_positions_invalid_game
		put '/3/games/30', {:userid => 3, :gameid => @game.id, :positions => [[1,1],[2,2]]},  'rack.session' => { :userid => 3 }
		assert_equal 401, last_response.status
	end

	def test_put_positions_game_started
		@game.start
		put '/3/games/' + @game.id.to_s, {:userid => 3, :gameid => @game.id, :positions => [[1,1],[2,2]]},  'rack.session' => { :userid => 3 }
		assert_equal 400, last_response.status
	end

end