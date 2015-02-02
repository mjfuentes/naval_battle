Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require File.expand_path '../../../gameController', __FILE__

class GameTests < Minitest::Test
	include Rack::Test::Methods			

	def app
		GameController
	end

	def teardown
		Player.delete_all
	end

	def test_get_players_not_logged_in
		get '/'
		assert_equal 400, last_response.status
	end

	def test_get_players_logged_in
		get '/', {}, 'rack.session' => { :userid => 1 }
		assert_equal 200, last_response.status
	end

	def test_get_player_not_logged_in
		get '/3'
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/', last_request.url
	end

	def test_get_player_logged_in_invalid_user
		get '/3', {}, 'rack.session' => { :userid => 1 }
		assert_equal 401, last_response.status
	end

	def test_get_player_logged_in_valid_user
		get '/3', {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_get_player_games_logged_in_valid_user
		get '/3/games', {}, 'rack.session' => { :userid => 3 }
		assert_equal 200, last_response.status
	end

	def test_get_player_games_logged_in_invalid_user
		get '/3/games', {}, 'rack.session' => { :userid => 2 }
		assert_equal 401, last_response.status
	end

	def test_create_user_valid
		post '/', {:username => 'nuevo', :name => 'nuevo', :password => '1234'}
		assert_equal 201, last_response.status
	end

	def test_create_user_username_already_used
		Player.create(name: 'pedro',username: 'nuevo', password: 'asdf')
		post '/', {:username => 'nuevo', :name => 'nuevo', :password => '1234'}
		assert_equal 409, last_response.status
	end

	def test_create_user_username_not_valid
		post '/', {:username => 'nombre con espacios', :name => 'nuevo', :password => '1234'}
		assert_equal 400, last_response.status
	end

end